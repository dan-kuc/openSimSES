%% LiB_Rosenkranz_CalAging: Cyclic aging model
% 
% Script to define function for an aging model 
% Cell type:    LiB
% Aging model:  Rosenkranz
% Model type:   Datasheet values
% Model source: Christian Rosenkranz (Johnson Controls) at EVS 20, Long Beach, CA, November 15-19, 2003
% Input values: Stress values
%   temperature                 % [K] Cell temperature 
%   avgCRate                    % [1/h] Average C-Rate of cycle
%   minSOC                      % [0-1] min SOC of cycle
%   maxSOC                      % [0-1] max SOC of cycle
%   cumRelCapacityThroughput)     % [pu] Cumulated relative capacity throughput until end of cycle since begin of life
%
% Output values: AgingCyclic
%   agingCyclic.relCapacityChange    % [pu]
%   agingCyclic.relResistanceChange  % [pu]
%
% Function owner: Maik Naumann
% Creation date: 12.01.2015
%
%%
function agingCyclic = LiB_Rosenkranz_CycAging(agingStress, ~, idxCalendarAging, idxCycleAging, ~, ~)

%% Input assignment
minSOC                      = agingStress.minSOC(idxCycleAging);
maxSOC                      = agingStress.maxSOC(idxCycleAging);

% Determine current DOC
DOC = abs(maxSOC - minSOC);

capacityLossOfEOLDefinition     = 0.2;                                  % [] Related capacity loss of EOL definition in aging data 
cyclesDepth                     = [0.025 0.05 0.10 0.25 0.50 0.80 1];   % []
nCyclesEOL                      = [4e5 2e5 4e4 1e4 4e3 3e3 3e3];        % []

% Create battery cycle lifetime function with Woehler curve
cycleLifetime   = interp1(cyclesDepth, nCyclesEOL, 0:0.01:1,'PCHIP');   % Cycle lifetime until 80% remaining capacity is reached;

% Calculate cyclic capacity change
agingCyclic.relCapacityChange    = - capacityLossOfEOLDefinition * 1/(2 * cycleLifetime(ceil(DOC * 100) + 1));  % [pu]

% Calculate cyclic resistance change
agingCyclic.relResistanceChange  = capacityLossOfEOLDefinition * 1/(2 * cycleLifetime(ceil(DOC * 100) + 1));  % [pu]

% Output of internal aging parameters
agingCyclic.capacityLossOfEOLDefinition = capacityLossOfEOLDefinition;
agingCyclic.equivalentFullCyclesEOL     = cycleLifetime(end);
agingCyclic.cycleLifetime               = cycleLifetime;

end

