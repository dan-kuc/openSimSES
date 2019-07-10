%% createBatteryReplacementData
% Returns battery replacement data which is applied when battery is
% replaced during storage simulation due to end-of-life.
%
% Input:
%   - replacementType [-] String: Case definition for selection of replacement data
%
% Output:
%   - replacementData [-] Struct: Struct with replacement parameters for
%                               setReplacement method
%
% This functions returns a struct which contains the necessary parameters
% for the setReplacement method in the storage class. The replacement
% parameters are given for different cases, which are selected by the input
% variable replacementType. The following replacementTypes are implement as 
% switch cases for the replacement data:
%   # Default
%   # Dummy
%
% 2017-08-04   Maik Naumann
%
%%
function [ replacementData ] = createBatteryReplacementData( replacementType )

%% Set default values for replacement parameters    
sohCapacity                 = 1; % [pu] SOH of storage capacity
sohResistance               = 1; % [pu] SOH of storage resistance   
cumAgingTime                = 0; % [s]  Cumulative aging time
cumRelChargeThroughput      = 0; % [pu] Cumulative relative charge throughput (FEC*2)
cumRelCapacityThroughput    = 0; % [pu] Cumulative relative capacity throughput 

%% Switch case for battery replacement values
switch lower(replacementType)
    % Sample case for replacement data
    case {'generic'}
        sohCapacity                 = 1;
        sohResistance               = 1;
        cumAgingTime                = 0;
        cumRelChargeThroughput      = 0;
        cumRelCapacityThroughput    = 0;
       
    otherwise % catch mistake of not specifying replacementType
        error([mfilename('fullpath') ': No replacement type selected to choose replacement data'])
end

% Write vars into output struct
replacementData.sohCapacity                 = sohCapacity;
replacementData.sohResistance               = sohResistance;
replacementData.cumAgingTime                = cumAgingTime;
replacementData.cumRelChargeThroughput      = cumRelChargeThroughput;
replacementData.cumRelCapacityThroughput    = cumRelCapacityThroughput;

end

