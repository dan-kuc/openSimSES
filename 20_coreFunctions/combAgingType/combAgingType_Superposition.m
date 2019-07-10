%% combAgingType_Superposition
% Script to define anonymous function for the combination of aging of the
% battery.
%
% Combination type: Superposition
% Description:      Simply sums up calendric and cyclic capacity and resistance change
% Input values:
%   agingCalendric              % Struct of calendric aging
%   agingCyclic                 % Struct of cyclic aging
%   passedTime                  % [s] Start point of time of aging 
%   cumRelCapacityThroughput)   % [pu] Cumulated relative capacity throughput until end of cycle since begin of life
%   temperature                 % [K] Cell temperature 
%   avgCRate                    % [1/h] Average C-Rate of cycle
%
% Output values:
%   agingTotal.relCapacityChange    % [pu]
%   agingTotal.relResistanceChange  % [pu]
%
% Function is referenced as function handle to calculate the total aging
% based on calendrical and cycle aging model.
%
% 2015-01-12 Maik Naumann
%
%%

function agingTotal = combAgingType_Superposition(agingCalendric, agingCyclic, agingStress, index, sampleTime)

% Calculate combination of aging
agingTotal.relCapacityChange    = agingCalendric.relCapacityChange + agingCyclic.relCapacityChange;
agingTotal.relResistanceChange  = agingCalendric.relResistanceChange + agingCyclic.relResistanceChange; 

end