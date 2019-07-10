%% CLFP_Goebel_CalAging: Literature cyclic aging model (A123 cell)
% 
% Script to define function for an aging model 
% Cell type:    C-LFP (A123 cell 2.3 Ah, Type No:  ANR26650 literature)
% Aging model:  Fitted model to literature data:
% Model type:   Literature: J. Wang, P. Liu, J. Hicks-Garner, E. Sherman, S. Soukiazian, M. Verbrugge,
%               H. Tataria, J. Musser, and P. Finamore, “Cycle-life Model for
%               Graphite-LiFePO4 Cells,” J. of Power Sources, vol. 196, no. 8, pp. 3942–
%               3948, 2011.
% Model source: Göbel, Hesse, Schimpe, Jossen, Jacobsen : IEEE Publication (submitted)
% Input values: 
%   temperature                 % [K] Cell temperature 
%   avgCRate                    % [1/h] Average C-Rate of cycle
%   cumRelCapacityThroughput    % [pu] Cumulated relative capacity throughput until end of cycle since begin of life
%   relCapacityThroughput       % [pu] Relative capacity throughput until end of cycle since begin of last cycle
%
% Output values: AgingCyclic
%   agingCyclic.relCapacityChange    % [pu]
%   agingCyclic.relResistanceChange  % [pu]
%
% Function owner: Holger Hesse
% Creation date: 05.02.2016
%
%%
function agingCyclic = CLFP_Goebel_CycAging(agingStress, ~, idxCalendarAging, idxCycleAging, ~, ~)

%% Input assignment
temperature                 = mean(agingStress.temperature(idxCalendarAging));
avgCRate                    = agingStress.avgCRate(idxCycleAging);
cumRelCapacityThroughput    = agingStress.cumRelCapacityThroughput;
minSOC                      = agingStress.minSOC(idxCycleAging);
maxSOC                      = agingStress.maxSOC(idxCycleAging);

% Determine current DOC
DOC = abs(maxSOC - minSOC);

%% Calculate cyclic aging
% No influence of charge direction
CRate = abs(avgCRate);
% Model is only valid between 0.5-2.0 C
if  CRate > 2
    warning('Model invalid - out of CRate bounds')
elseif CRate < 0.5 
    CRate = 0.5; % Lower CRate values would lead to cyclic aging smaller than calendric aging
end

% Beta parameter fitted by Goebel, Hesse et al.
b8  = 31630 - (2 * CRate/3 - 1/3) * 9949;

% Beta parameters from the publication
b9  = 370.3 * CRate - 31700;
b10 = 0.55;

R_gas = 8.31446; % [J/(K*mol)] Ideal gas constant

% Relate cumulated relative charge througput to capacity considered in model
A123_cap_const = 2.3; % [Ah] Capacity of related C-LFP cell
Ah_trough1 = (cumRelCapacityThroughput - DOC)   * A123_cap_const;
Ah_trough2 = cumRelCapacityThroughput           * A123_cap_const;

% Calculate relative capacity change
agingCyclic.relCapacityChange    = -(((b8 * exp(b9 / (R_gas * temperature)) * Ah_trough2^b10) - ...
                                    (b8 * exp(b9 / (R_gas * temperature)) * Ah_trough1^b10)) / 100); % [pu]  

% Calculate resistance change
% Resistance change is not reflected in this model
agingCyclic.relResistanceChange  = 0; % [pu]

% Output of internal aging parameters
agingCyclic.capacityLossOfEOLDefinition  = 0.8;
agingCyclic.equivalentFullCyclesEOL      = 3624.6; % Cycle lifetime according to formula until 80% SOH
agingCyclic.cycleLifetime                = 3624.6; % Cycle lifetime according to formula until 80% SOH

end

