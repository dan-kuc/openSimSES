%% NMC_Molicel_IHR18650A_CycAging: Cyclic aging model
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
%   agingCyclic.relCapacityChange    % [pu]
%   agingCyclic.relResistanceChange  % [pu]
%
% Function owner: Yulong Zhao
% Creation date: 13.12.2018

%%
function agingCyclic = NMC_Molicel_IHR18650A_CycAging(agingStress, agingMdl, ~, index, totalRelCapacityChangeNow, totalRelResistanceChangeNow)

%% Input assignment
avgCRate            = agingStress.avgCRate(index);
minSOC              = agingStress.minSOC(index);
maxSOC              = agingStress.maxSOC(index);
Q1                  = agingStress.cumRelCapacityThroughput*(1 + totalRelCapacityChangeNow)*1.95; % total capacity throughput until now [p.u.]

% Determine current DOC
DOC     = abs(maxSOC - minSOC);
delta_Q = DOC*(1 + totalRelCapacityChangeNow)*1.95; % charge throughput in current half cycle in Ah

%% Calculate stress factors for cyclic ageing
DOD_ind  = agingMdl.index_DOD; % x values for aging factor matrix
ca_mtx   = agingMdl.k_ca_cyc ; % ageing factor matrix for calendar ageing capacity loss
ri_mtx   = agingMdl.k_ri_cyc; % ageing factor matrix for calendar ageing resistance increase 

k_ca_cyc = interp1(DOD_ind, ca_mtx, DOC);
k_ri_cyc = interp1(DOD_ind, ri_mtx, DOC);
%% Calculate cycle aging
% Negative sign for capacity change necessary, since positive sign would lead to capacity increase
if avgCRate <= -0.5
    k_ca_cyc = k_ca_cyc/(1.1587)*(1.1587)^(log2(avgCRate/-0.5)); % corerction necessary
    %k_ri_cyc = k_ri_cyc; % no correction necessary
elseif avgCRate > -0.5 && avgCRate < 0.5
    %k_ca_cyc = k_ca_cyc; % no correction necessary
    %k_ri_cyc = k_ri_cyc; % no correction necessary
else
    k_ca_cyc = k_ca_cyc*(1.569)^(log2(avgCRate/0.5)); % corerction necessary
    k_ri_cyc = k_ri_cyc*(1.21)^(log2(avgCRate/0.5)); % corerction necessary
end

agingCyclic.relCapacityChange   = - (k_ca_cyc*(Q1)^0.5562 - k_ca_cyc*(Q1-delta_Q)^0.5562);
agingCyclic.relResistanceChange = k_ri_cyc*(Q1)^0.5562 - k_ri_cyc*(Q1-delta_Q)^0.5562;

end