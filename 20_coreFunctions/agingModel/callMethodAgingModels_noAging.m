%% callMethodAgingModels_NoAging
% 
% Returns battery's aging with zero values in case simulation 
% is executed with no stress characterization and no consecutive aging.
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
% This functions returns the battery's aging stress and aging with zero values
% 
% 2017-08-04   Maik Naumann
%
%%

function [detectedStress, agingCalendric, agingCyclic, agingTotal] = callMethodAgingModels_noAging( ees )

% Assign zero values to aging result structs
agingCalendric.relCapacityChange    = 0;
agingCalendric.relResistanceChange  = 0;
agingCyclic.relCapacityChange       = 0;
agingCyclic.relResistanceChange     = 0;

% Get total aging with zero values
% agingTotal = ees.inputTech.combAgingFct(); 
agingTotal.relCapacityChange        = 0; % [pu]
agingTotal.relResistanceChange      = 0; % [pu]


%% Prepare logging of aging stress with zero values
detectedStress.cumAgingTime                = 0;
detectedStress.cumRelCapacityThroughput    = 0;
detectedStress.lastCycle                   = 0;
detectedStress.minSOC                      = 0;
detectedStress.maxSOC                      = 0;
detectedStress.avgCRate                    = 0;
detectedStress.avgSOC                      = 0;

end