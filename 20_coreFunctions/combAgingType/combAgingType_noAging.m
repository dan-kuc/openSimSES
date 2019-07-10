%% combAgingType_NoAging
% Script to define anonymous function for the combination of aging of the
% battery.
%
% Combination type: No aging
% Description:      Return in every case no aging
%
% Output values:
%   agingTotal.relCapacityChange    % [pu]
%   agingTotal.relResistanceChange  % [pu]
%
% Function is referenced as function handle to calculate the total aging
% based on calendrical and cycle aging model.
%
% 2015-03-29 Maik Naumann
%
%%

function agingTotal = combAgingType_NoAging(~, ~, ~, ~, ~)

% Calculate combination of aging
agingTotal.relCapacityChange    = 0; % [pu]
agingTotal.relResistanceChange  = 0; % [pu]

end