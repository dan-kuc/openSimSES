%% setReplacement
%   Resets the battery SOC, SOH and aging stress to the values given by the
%   replacement data struct of the EES object
%
%   Input/Output: EES object
%
%   This functions is called when the battery reaches a certain end-of-life
%   criteria, which is analyzed in every call of the step-function of the EES
%   object.
%
%   Resets battery's SOC, SOH and aging stress parameters of the EES object 
%   to the values given by the replacement data. The replacement data is 
%   defined when creating the EES object.
%   The replacement action and time is logged with the parameter storageReplacement. 
%
%   2017-08-04   Maik Naumann
%%
function [ ees ] = setReplacement( ees )

% Update vector of storage replacement time 
ees.storageReplacement = [ees.storageReplacement ees.kNow];

% Reset current SOC to start value
ees.socNow              = ees.inputTech.soc0;
ees.soc(ees.kNow)       = ees.inputTech.soc0;

% Reset storage capacity and SOH values to given values for replacement
ees.sohCapNow      = ees.inputTech.replaceParam.sohCapacity;       
ees.sohResNow      = ees.inputTech.replaceParam.sohResistance;       

% If logging of aging stress is activated, current step is used for loggingIndex
if(ees.inputSim.flagLogAging)                                            
    idxLogging          = ees.kNow;
else
    idxLogging          = 1;
end

disp(['Storage replacement at simulation time: ', num2str(ees.tNow), ' seconds']);

%% Reset stress parameters for proper restart of stress detection

% Reset cumulative aging time to start from beginning of life of aging behavior
ees.agingStress.cumAgingTime            = ees.inputTech.replaceParam.cumAgingTime;

% Reset cumulative relative charge througput to start from beginning of life of aging behavior
ees.agingStress.cumRelChargeThroughput   = ees.inputTech.replaceParam.cumRelChargeThroughput; 
ees.agingStress.cumRelCapacityThroughput = ees.inputTech.replaceParam.cumRelCapacityThroughput; 

% Reset further stress parameters
ees.agingStress.lastCycle(idxLogging)               = 0;
ees.agingStress.minSOC(idxLogging)                  = 0;
ees.agingStress.maxSOC(idxLogging)                  = 0;
ees.agingStress.avgCRate(idxLogging)                = 0;
ees.agingStress.avgSOC(idxLogging)                  = 0;

end

