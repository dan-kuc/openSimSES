%% callMethodAgingModels_SingleValues
% 
% Returns battery's aging stress and degradation by calling aging models 
% with single values of the stress characterization.
%
% Input: EES object
%
% Output:
%   detectedStress  [-]     Struct containing the aging stress values
%   agingCalendric  [pu]    Struct containing the relative calendric 
%                           capacity and resistance degradation
%   agingCyclic     [pu]    Struct containing the relative calendric 
%                           capacity and resistance degradation
%   agingTotal      [pu]    Struct containing the relative total 
%                           capacity and resistance degradation
%
% This functions returns the battery's aging stress, capacity and 
% resistance degradation. The battery aging is calculated by calling the 
% aging models with single values of the stress characterization.
% Calendric and cyclic aging are calculated seperatly with the aging models 
% defined in the EES object.
% The results of the calendar and cyclic aging model are then combined 
% within the function combAgingFct to get the total aging values.
% 
% 2018-01-09   Maik Naumann
%
%%

function [detectedStress, agingCalendric, agingCyclic, agingTotal] = callMethodAgingModels_SingleValues( EES )

%% Assign inputs
stepNow                         = EES.stepNow;
stepBefore                      = max(stepNow - 1,1);
stepSize                        = EES.inputTech.stepSizeStressCharacterization;
SOHCapacityNow                  = EES.SOHCapacityNow;
sampleTime                      = EES.sampleTimeNow;
agingStress                     = EES.agingStress;
stressCharacterization          = EES.stressCharacterization;

% Get indeces
idxCalendarAging    = (max(stepNow - EES.inputTech.stepSizeCalendarAging + 1,1) : stepNow);
idxCycleAging       = 1;

% Assign default values to aging result structs
agingCalendric.relCapacityChange    = 0;
agingCalendric.relResistanceChange  = 0;
agingCyclic.relCapacityChange       = 0;
agingCyclic.relResistanceChange     = 0;

%% Get stress characateristics for aging models
% Default value indepent from stress characterization
detectedStress.lastCycle(1:stepSize)    = 0;
detectedStress.minSOC(1:stepSize)       = 0;
detectedStress.maxSOC(1:stepSize)       = 0;
detectedStress.avgCRate(1:stepSize)     = 0;
detectedStress.avgSOC(1:stepSize)       = 0;
detectedStress.idxLogging(1:stepSize)   = stepNow;

%% Select SOC and temperature values of last simulation loop
SOC         = EES.SOC(stepBefore:stepNow);
deltaSOC    = abs(diff([SOC(1:end),0]));

%% Check if agingStress is available from stress characterization (stepSize match or finalSimLoop)
if(mod(stepNow, stepSize) == 0 || stressCharacterization.finalSimLoop)
    % Characerization with half-cycle counting
    lastCycle = stressCharacterization.agingStress.lastCycle(end);
    % Check if cycle end was detected with half-Cycle characterization method
    if(lastCycle >= (stepNow - stepSize) || stressCharacterization.finalSimLoop)
        % Get stress values out of stress characterization
        detectedStress  = stressCharacterization.agingStress;
        % Get index of end of last cycle
        idxCycleAging   = find(detectedStress.idxLogging == detectedStress.lastCycle(end));
    end
end

%% Calculate aging after stress characterization with single values
% Update mean SOC for calendric aging (different to avgSOC for cycle aging)
detectedStress.meanSOC      = EES.SOC(idxCalendarAging);

% Update temperature for aging models
detectedStress.temperature  = EES.temperature(idxCalendarAging);

% Update calendar aging index
idxCalendarAging            = 1:EES.inputTech.stepSizeCalendarAging;

% Update cumulative aging time
detectedStress.cumAgingTime             = agingStress.cumAgingTime + sampleTime; % [s]

% Update cumulative capacity throughput
detectedStress.relCapacityThroughput    = deltaSOC(1) * SOHCapacityNow;
detectedStress.cumRelCapacityThroughput = agingStress.cumRelCapacityThroughput + detectedStress.relCapacityThroughput;

% Calculate calendric aging with selected step size
if(mod(stepNow, EES.inputTech.stepSizeCalendarAging) == 0)
    for i = 1:EES.inputTech.stepSizeCalendarAging
        % Calculate aging through calendric aging function
        agingCalendric_temp = EES.inputTech.agingModel.calAgingFct(detectedStress, EES.inputTech.agingModel, idxCalendarAging(i), sampleTime, EES.totalRelCapacityChangeCalendricNow, EES.totalRelResistanceChangeCalendricNow);
        % If calendric aging model outputs NaN values, aging is set to 0
        if(isnan(agingCalendric_temp.relCapacityChange) || isnan(agingCalendric_temp.relResistanceChange))
            %     disp('Calendric aging out of bounds with NaN values: Output is set to 0')
            agingCalendric_temp.relCapacityChange     = 0;
            agingCalendric_temp.relResistanceChange   = 0;
        end
        % Sum up all aging results
        agingCalendric.relCapacityChange    = agingCalendric.relCapacityChange      + agingCalendric_temp.relCapacityChange;
        agingCalendric.relResistanceChange  = agingCalendric.relResistanceChange    + agingCalendric_temp.relResistanceChange;
    end
end

% Calculate cycle aging with selected step size
if(mod(EES.stepNow, EES.inputTech.stepSizeCycleAging) == 0)
    % Calculate aging through cyclic aging function 
    % Calculate cycle depth (DOC)
    DOC = abs(detectedStress.maxSOC(idxCycleAging) - detectedStress.minSOC(idxCycleAging));
    % Only calculate cycle aging if 
    %   - Cycle was detected (avgCRate of cycle ~= 0)
    %   and DOC > DOCThreshold for given aging model
    if(detectedStress.avgCRate(idxCycleAging) && DOC > EES.inputTech.agingModel.DOCThresh)
        agingCyclic_temp = EES.inputTech.agingModel.cycAgingFct(detectedStress, EES.inputTech.agingModel, idxCalendarAging, idxCycleAging, EES.totalRelCapacityChangeNow, EES.totalRelResistanceChangeNow);
        % If cyclic aging model outputs NaN values, aging is set to 0
        if(isnan(agingCyclic_temp.relCapacityChange) || isnan(agingCyclic_temp.relResistanceChange))
            %     disp('Calendric aging out of bounds with NaN values: Output is set to 0')
            agingCyclic_temp.relCapacityChange    = 0;
            agingCyclic_temp.relResistanceChange  = 0;
        end
        % Sum up all aging results
        agingCyclic.relCapacityChange    = agingCyclic.relCapacityChange      + agingCyclic_temp.relCapacityChange;
        agingCyclic.relResistanceChange  = agingCyclic.relResistanceChange    + agingCyclic_temp.relResistanceChange;
    end
end

% Calculate total aging with function handle for combination of aging factors
agingTotal = EES.inputTech.combAgingFct(agingCalendric, agingCyclic, detectedStress, stepNow, sampleTime); 

end