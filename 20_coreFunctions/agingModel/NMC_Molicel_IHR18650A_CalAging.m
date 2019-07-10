%% NMC_Molicel_IHR18650A_CalAging: Calendric aging model
% 
% Script to define function for an aging model 
% Cell type:    Molicel IHR18650A
% Aging model:  Molicel IHR18650A
% Model type:   Datasheet fit
% Model source: MA Ni EES/TUM
% Stress values:
%   time1       % [s] Start point of time of aging 
%   time2       % [s] End point of time of aging
%
% Output values: AgingCalendric
%   agingCalendric.relCapacityChange    % [pu]
%   agingCalendric.relResistanceChange  % [pu]
%
% Function owner: Yulong Zhao
% Creation date: 13.12.2018

function agingCalendric = NMC_Molicel_IHR18650A_CalAging(agingStress, agingMdl, index, sampleTime, totalRelCapacityChangeCalendricNow, totalRelResistanceChangeCalendricNow)

%% read detected stress factors 
T   = (mean(agingStress.temperature(index)) - 273.15)*1.3;
SOC = mean(agingStress.meanSOC(index));
ta  = agingStress.cumAgingTime/(86400*7) + sampleTime/(86400*7); % cummulative aging time in weeks
%% retrieve stress factors for ageing calculation
soc_ind  = agingMdl.index_soc; % x values for aging factor matrix
T_ind    = agingMdl.index_T; % y values for ageing factor matrix
ca_mtx   = agingMdl.k_ca_cal ; % ageing factor matrix for calendar ageing capacity loss
ri_mtx   = agingMdl.k_ri_cal; % ageing factor matrix for calendar ageing resistance increase 

% calculate ageing factors with interpolation 
k_ca_cal = interp2(soc_ind, T_ind, ca_mtx, SOC, T);
k_ri_cal = interp2(soc_ind, T_ind, ri_mtx, SOC, T);

%% calculate equivalent calendar ageing time now
% t1_Q           = (-totalRelCapacityChangeCalendricNow/k_ca_cal)^(4/3); % ageing time in weeks
% t2_Q           = t1_Q + sampleTime/(86400*7);
% t1_R           = (-totalRelResistanceChangeCalendricNow/k_ri_cal)^(2); % ageing time in weeks
% t2_R           = t1_R + sampleTime/(86400*7);

%% Calculate calendric aging

% Calculate relative capacity fade
%agingCalendric.relCapacityChange    = - (k_ca_cal*t2_Q^0.75 - totalRelCapacityChangeCalendricNow);
agingCalendric.relCapacityChange    = - (k_ca_cal*ta^0.75 - k_ca_cal*(ta - sampleTime/(86400*7))^0.75);
% Calculate resistance increase
% Resistance change is not reflected in this model
%agingCalendric.relResistanceChange  = k_ri_cal*t2_R^0.5 - totalRelResistanceChangeCalendricNow; % [pu]
agingCalendric.relResistanceChange  = k_ri_cal*ta^0.5 - k_ri_cal*(ta - sampleTime/(86400*7))^0.5;
end