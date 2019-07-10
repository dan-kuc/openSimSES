%% callMethodAgingModels_AverageValues
% 
% Returns battery's aging stress and degradation by calling the aging models 
% with average values of the stress characterization.
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
% aging models with average values of the stress characterization.
% Calendric and cyclic aging are calculated seperatly with the aging models 
% defined in the EES object.
% The results of the calendar and cyclic aging model are then combined 
% within the function combAgingFct to get the total aging values.
% 
% 2018-01-09   Maik Naumann
%
%%

function [detectedStress, agingCal, agingCyc, agingTotal] = callMethodAgingModels_AverageValues( ees )

%% Assign inputs
kNow            = ees.kNow;
kPrev           = max(kNow - 1,1);
stepSize        = ees.inputTech.stepSzStressCharact;
sohCapNow       = ees.sohCapNow;
tSample         = ees.tSampleNow;
agingStress     = ees.agingStress;
stressCharact   = ees.stressCharacterization;
steps           = 1:stepSize;

% Get indeces
idxCalAging     = (max(kNow - ees.inputTech.stepSzCalAging + 1,1) : kNow);
idxCycAging     = 1;

% Assign default values to aging result structs
agingCal.relCapacityChange      = 0;
agingCal.relResistanceChange    = 0;
agingCyc.relCapacityChange      = 0;
agingCyc.relResistanceChange    = 0;

%% Get stress characateristics for aging models
% Default value indepent from stress characterization
detectedStress.lastCycle(steps)    = 0;
detectedStress.minSOC(steps)       = 0;
detectedStress.maxSOC(steps)       = 0;
detectedStress.avgCRate(steps)     = 0;
detectedStress.avgSOC(steps)       = 0;
detectedStress.idxLogging(steps)   = kNow;

%% Select SOC and temperature values of last simulation loop
soc         = ees.soc(kPrev:kNow);
deltaSOC    = abs(diff([soc(1:end),0]));

%% Check if agingStress is available from stress characterization (stepSize match or finalSimLoop)
if(mod(kNow, stepSize) == 0 || stressCharact.finalSimLoop)
    % Characerization with half-cycle counting
    lastCycle = stressCharact.agingStress.lastCycle(end);
    % Check if cycle end was detected in with Half-Cycle characterization method
    if(lastCycle >= (kNow - stepSize) || stressCharact.finalSimLoop)
        % Get stress values out of stress characterization
        detectedStress  = stressCharact.agingStress;
        % Get index of end of last cycle
        idxCycAging   = find(detectedStress.idxLogging == detectedStress.lastCycle(end));
    end
end

%% Calculate aging after stress characterization with average values
detectedStress.meanSOC      = mean(ees.soc(idxCalAging));           % [pu] mean SOC for calendric aging (different to avgSOC for cycle aging)
detectedStress.temperature  = mean(ees.temperature(idxCalAging));   % [K] temperature for aging models
detectedStress.cumAgingTime = agingStress.cumAgingTime + tSample;   % [s] cumulative aging time

% Update cumulative capacity throughput
detectedStress.relCapacityThroughput    = deltaSOC(1) * sohCapNow;
detectedStress.cumRelCapacityThroughput = agingStress.cumRelCapacityThroughput + detectedStress.relCapacityThroughput;

% Calculate calendric aging with selected step size
if(mod(kNow, ees.inputTech.stepSzCalAging) == 0)
    % Calculate aging through calendric aging function
    agingCalendric_temp = ees.inputTech.agingMdl.calAgingFct(detectedStress, ees.inputTech.agingMdl, 1, tSample * ees.inputTech.stepSzCalAging, ees.totalRelCapacityChangeCalendricNow, ees.totalRelResistanceChangeCalendricNow);
    % If calendric aging model outputs NaN values, aging is set to 0
    if(isnan(agingCalendric_temp.relCapacityChange) || isnan(agingCalendric_temp.relResistanceChange))
        %     disp('Calendric aging out of bounds with NaN values: Output is set to 0')
        agingCalendric_temp.relCapacityChange     = 0;
        agingCalendric_temp.relResistanceChange   = 0;
    end
    % Sum up all aging results
    agingCal.relCapacityChange    = agingCal.relCapacityChange      + agingCalendric_temp.relCapacityChange;
    agingCal.relResistanceChange  = agingCal.relResistanceChange    + agingCalendric_temp.relResistanceChange;
end

% Calculate cycle aging with selected step size
if(mod(ees.kNow, ees.inputTech.stepSzCycAging) == 0)
    % Calculate aging through cyclic aging function
    % Calculate cycle depth (DOC)
    DOC = abs(detectedStress.maxSOC(idxCycAging) - detectedStress.minSOC(idxCycAging));
    % Only calculate cycle aging if 
    %   - Cycle was detected (avgCRate of cycle ~= 0)
    %   and DOC > DOCThreshold for given aging model
    if(detectedStress.avgCRate(idxCycAging) && DOC > ees.inputTech.agingMdl.DOCThresh)
        agingCyclic_temp = ees.inputTech.agingMdl.cycAgingFct(detectedStress, ees.inputTech.agingMdl, 1, idxCycAging, ees.totalRelCapacityChangeNow, ees.totalRelResistanceChangeNow);
        % If cyclic aging model outputs NaN values, aging is set to 0
        if(isnan(agingCyclic_temp.relCapacityChange) || isnan(agingCyclic_temp.relResistanceChange))
            %     disp('Calendric aging out of bounds with NaN values: Output is set to 0')
            agingCyclic_temp.relCapacityChange    = 0;
            agingCyclic_temp.relResistanceChange  = 0;
        end
        % Sum up all aging results
        agingCyc.relCapacityChange    = agingCyc.relCapacityChange      + agingCyclic_temp.relCapacityChange;
        agingCyc.relResistanceChange  = agingCyc.relResistanceChange    + agingCyclic_temp.relResistanceChange;
    end
end

% Calculate total aging with function handle for combination of aging factors
agingTotal = ees.inputTech.combAgingFct(agingCal, agingCyc, detectedStress, kNow, tSample); 

end