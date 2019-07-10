%% detectHalfCycles
%
% Returns the aging stress characterized by half-cycle analysis
% 
% Input/Output: StressCharacterization object
%
% This functions characterizes the battery stress by half-cycle analysis
% of the SOC and returns the aging stress which is the required input for 
% the aging models.
% Half-cycle analysis is an event-based stress characterization method,
% and analyzes the half-cycles / stress by detecting the following events:
%   1. Sign change of load (from charge to discharge or vice versa)
%   2. Change from charge/discharge to idle mode or vice versa
%   3. Relative strong change of gradient during charge or discharge
% When a half-cycle is detected, the parameters the half-cycle's cycle
% depth (minSOC, maxSOC), avergage SOC (avgSOC) and average C-rate
% (avgCRate) are calculated and stored in the agingStress struct.
% 
% 2017-08-04   Maik Naumann


%%

function [SC] = detectHalfCycles(SC)

%% Assign inputs
finalSimLoop    = SC.finalSimLoop;
time            = SC.Data2beCharacterized(:,1);
SOC             = SC.Data2beCharacterized(:,2);
sampleTime      = SC.sampleTime;
agingStress     = SC.agingStress;
SOCThresh       = SC.SOCThreshold;
SOCSlopeThresh  = SC.SOCSlopeThreshold;
DOCThresh       = SC.DOCThreshold;  

% Define step variable
stepNow         = max(time(end)/sampleTime,1);
stepBefore      = max(agingStress.idxLogging(end),1);
stepSize        = max(stepNow - stepBefore,1); 

% Define indices for last detected cycle
lastCycle       = agingStress.lastCycle(end);
idxLastCycle    = find(agingStress.idxLogging==lastCycle);

% Initialize aging stress in first step
if(stepNow <= stepSize)
    agingStressNew.idxLogging                           = 1:stepSize;
    agingStressNew.lastCycle(agingStressNew.idxLogging) = lastCycle;
    agingStressNew.SOC(agingStressNew.idxLogging)       = SOC';
    agingStressNew.minSOC(agingStressNew.idxLogging)    = 0;
    agingStressNew.maxSOC(agingStressNew.idxLogging)    = 0;
    agingStressNew.avgCRate(agingStressNew.idxLogging)  = 0;
    agingStressNew.avgSOC(agingStressNew.idxLogging)    = 0;
    agingStress = agingStressNew;
% If cycle was detected in last step, reset logging of aging stress to save memory
elseif(lastCycle >= stepBefore - stepSize || finalSimLoop)
    agingStressNew.lastCycle    = [agingStress.lastCycle(idxLastCycle:end), repmat(lastCycle, 1, stepSize)];
    agingStressNew.SOC          = [agingStress.SOC(idxLastCycle:end), SOC(end-(stepSize-1):end)'];
    agingStressNew.minSOC       = [agingStress.minSOC(idxLastCycle:end), zeros(1, stepSize)];
    agingStressNew.maxSOC       = [agingStress.maxSOC(idxLastCycle:end), zeros(1, stepSize)];
    agingStressNew.avgCRate     = [agingStress.avgCRate(idxLastCycle:end), zeros(1, stepSize)];
    agingStressNew.avgSOC       = [agingStress.avgSOC(idxLastCycle:end), zeros(1, stepSize)];
    agingStressNew.idxLogging   = [agingStress.idxLogging(idxLastCycle:end):stepNow];
    agingStress = agingStressNew;
% Update aging stress if cycle is still running
else
    % Update aging stress logging index
    agingStress.idxLogging  = [agingStress.idxLogging, agingStress.idxLogging(end)+1:agingStress.idxLogging(end)+stepSize];
    idxLoggingNew           = length(agingStress.idxLogging)-stepSize+1:length(agingStress.idxLogging); 
    % Save end index of last cycle for next cycle detected
    agingStress.lastCycle(idxLoggingNew)    = lastCycle;
    agingStress.SOC(idxLoggingNew)          = SOC(1:length(idxLoggingNew))';
    agingStress.minSOC(idxLoggingNew)       = 0;
    agingStress.maxSOC(idxLoggingNew)       = 0;
    agingStress.avgCRate(idxLoggingNew)     = 0;
    agingStress.avgSOC(idxLoggingNew)       = 0;
end
  
%% Detect half cycles by evaluating SOC profile
% Cycle detection starts after first step
if (stepNow > 1)
    % Select SOC values since start of current cycle
    SOC = agingStress.SOC(agingStress.idxLogging>=lastCycle);
    % Analyze current SOC profile for half cycles
    for t = 3:length(SOC)
        % Reset flag for detected end of half cycle
        isCycleDetected = false;

        %% Half cycle end detection (End of lastcycle = Start of new cycle)
        % Sign change of load
        if (~isequal(sign(diff(SOC(t-2:t-1))), sign(diff(SOC(t-1:t)))))
            isCycleDetected = true;
        % Load change from zero and not only self-discharge
        elseif (-abs(diff(SOC(t-2:t-1))) >= -SOCThresh && abs(diff(SOC(t-1:t))) > SOCThresh)
            isCycleDetected = true;
        % Load change to zero or only self-discharge
        elseif(abs(diff(SOC(t-2:t-1))) > SOCThresh && abs(diff(SOC(t-1:t))) < SOCThresh)
            isCycleDetected = true;
        % SOC gradient change bigger than SOC slope threshold
        elseif(abs(diff([abs(diff(SOC(t-2:t-1))), abs(diff(SOC(t-1:t)))])) > SOCSlopeThresh)
            isCycleDetected = true;
        % If final simulation reached, finish current cycle
        elseif(finalSimLoop && t == length(SOC))
            isCycleDetected = true;
        end
        
        %% Determine the cycle stress if cycle end was detected
        if(isCycleDetected)
            % Calculate cycle depth
            cycleDepth                  = diff([SOC(t-1),SOC(1)]);
            % Log end step of last cycle
            agingStress.lastCycle(t-1)  = lastCycle;
            % Log start step of new cycle
            agingStress.lastCycle(t:end)= agingStress.idxLogging(t-1);
            % Only detect cycle if DOC is bigger than threshold for cycle detection
            if(abs(cycleDepth) > DOCThresh)
                % Considered SOC: Values of steps between end of last cycle and end of current cycle
                agingStress.minSOC(2:t-1) = min(SOC(1:t-1));
                agingStress.maxSOC(2:t-1) = max(SOC(1:t-1));
                agingStress.avgSOC(2:t-1) = mean(SOC(1:t-1));
                % Considered power: Values of steps between step after end of last cycle and last step of current cycle
                agingStress.avgCRate(2:t)   = cycleDepth / ((t-2) * sampleTime / 3600);
            end
        end
    end
end

% Update aging stress
SC.agingStress = agingStress;
end