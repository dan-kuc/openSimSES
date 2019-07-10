%% CLFP_Sony_US26650_Experiment_CalAging: Calendric aging model
% 
% Script to define function for an aging model 
% Cell type:    C-LFP
% Aging model:  Fitted model of experimental data
% Model type:   Semi-empirical
% Model source: Proprietary: Aging study by MN at EES 2014-2017
% Stress values:
%   temperature % [K] Cell temperature 
%   avgSOC      % [0-1] Average SOC between time1 and time2
%   totalRelCapacityChangeCalendric    % [pu] Total relative capacity change due to calendar aging
%   totalRelResistanceChangeCalendric  % [pu] Total relative resistance change due to calendar aging
%
% Output values: AgingCalendric
%   agingCalendric.relCapacityChange    % [pu]
%   agingCalendric.relResistanceChange  % [pu]
%
% Function owner: Maik Naumann
% Creation date: 03.11.2017
%
%%
function agingCalendric = CLFP_Sony_US26650_Experiment_CalAging(agingStress, agingModel, index, sampleTime, totalRelCapacityChangeCalendricNow, totalRelResistanceChangeCalendricNow)

%% Input assignment
temperature         = mean(agingStress.temperature(index));
avgSOC              = mean(agingStress.meanSOC(index));
CalAging_Cap        = agingModel.calAgingCapFct;
CalAging_Res        = agingModel.calAgingResFct;
CalAging_Cap_Index  = agingModel.calAgingCapFctIndex;
CalAging_Res_Index  = agingModel.calAgingCapFctIndex;

%% Calculate time index for current stress values
time_CalAging_Cap = CalAging_Cap_Index(temperature, avgSOC,  -totalRelCapacityChangeCalendricNow * 100);
time_CalAging_Res = CalAging_Res_Index(temperature, avgSOC,  totalRelResistanceChangeCalendricNow * 100);

%% Calculate calendric aging
% Negative sign for capacity change necessary, since positive sign would lead to capacity increase
agingCalendric.relCapacityChange    = -integral(@(Time)CalAging_Cap(temperature, avgSOC, Time), time_CalAging_Cap, time_CalAging_Cap + sampleTime)/100; % [pu]     
% Correction factor 0.5 necessary to get proper values for resistance increase
agingCalendric.relResistanceChange  = 0.5 * integral(@(Time)CalAging_Res(temperature, avgSOC, Time), time_CalAging_Res, time_CalAging_Res + sampleTime,'ArrayValued',true)/100; % [pu]

end
