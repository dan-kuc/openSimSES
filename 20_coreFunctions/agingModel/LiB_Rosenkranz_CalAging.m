%% LiB_Rosenkranz_CalAging: Calendric aging model
% 
% Script to define function for an aging model 
% Cell type:    LiB
% Aging model:  Rosenkranz
% Model type:   Datasheet values
% Model source: SEFEP study 2012, RTWH Aachen
% Stress values:
%   temperature % [K] Cell temperature 
%   avgSOC      % [0-1] Average SOC between time1 and time2
%   time1       % [s] Start point of time of aging 
%   time2       % [s] End point of time of aging
%
% Output values: AgingCalendric
%   agingCalendric.relCapacityChange    % [p.u.]
%   agingCalendric.relResistanceChange  % [p.u.]
%
% Function owner: Maik Naumann
% Creation date: 12.01.2015
%
%%
function agingCalendric = LiB_Rosenkranz_CalAging(agingStress, ~, ~, sampleTime, ~, ~)

%% Input assignment
time1           = agingStress.cumAgingTime;
time2           = agingStress.cumAgingTime + sampleTime;

capacityLossOfEOLDefinition     = 0.2;                      % []    Related capacity loss of EOL definition in aging data 
calendricLifetime               = 15 * (365 * 24 * 3600);   % [s]   15 years calendric lifetime until 80% remaining capacity [sec]

% Calculate calendric aging
agingCalendric.relCapacityChange    = -capacityLossOfEOLDefinition * (time2-time1)/(calendricLifetime);    % [p.u.] agingCalendric.relCapacityChange
agingCalendric.relResistanceChange  = capacityLossOfEOLDefinition * (time2-time1)/(calendricLifetime);    % [p.u.] agingCalendric.relResistanceChange

% Output of internal aging parameters
agingCalendric.capacityLossOfEOLDefinition  = capacityLossOfEOLDefinition;
agingCalendric.calendricLifetime            = calendricLifetime;

end
