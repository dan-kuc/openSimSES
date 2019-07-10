%% CLFP_Sony_US26650_Experiment_CycAging: Cycle aging model
% 
% Script to define function for an aging model 
% Cell type:    C-LFP
% Aging model:  Fitted model of experimental data
% Model type:   Semi-empirical
% Model source: Proprietary: Aging study by MN at EES 2014-2017
% Stress values:
%   avgCRate                    % [1/h] Average C-Rate of cycle
%   DOC                         % [0-1] DOC of cycle
%   totalRelCapacityChangeCalendric    % [pu] Total relative capacity change due to calendar aging
%   totalRelResistanceChangeCalendric  % [pu] Total relative resistance change due to calendar aging
%
% Output values: AgingCalendric
%   agingCyclic.relCapacityChange    % [pu]
%   agingCyclic.relResistanceChange  % [pu]
%
% Function owner: Maik Naumann
% Creation date: 03.11.2017
%
%%
function agingCalendric = CLFP_Sony_US26650_Experiment_CycAging(agingStress, agingModel, ~, index, totalRelCapacityChangeNow, totalRelResistanceChangeNow)

%% Input assignment
avgCRate            = agingStress.avgCRate(index);
minSOC              = agingStress.minSOC(index);
maxSOC              = agingStress.maxSOC(index);
CycAging_Cap        = agingModel.cycAgingCapFct;
CycAging_Res        = agingModel.cycAgingResFct;
CycAging_Cap_Index  = agingModel.cycAgingCapFctIndex;
CycAging_Res_Index  = agingModel.cycAgingCapFctIndex;

% Determine current DOC
DOC = abs(maxSOC - minSOC);

%% Calculate FEC for current stress values
% Factor 100 necessary for conversion of pu in percent values
fec_CycAging_Cap = CycAging_Cap_Index(abs(avgCRate), DOC,  -totalRelCapacityChangeNow * 100);
fec_CycAging_Res = CycAging_Res_Index(abs(avgCRate), DOC,  totalRelResistanceChangeNow * 100);

%% Calculate cycle aging
% Factor 100 necessary for conversion from percent in pu values
% Negative sign for capacity change necessary, since positive sign would lead to capacity increase
agingCalendric.relCapacityChange    = -integral(@(FEC)CycAging_Cap(abs(avgCRate), DOC, FEC), fec_CycAging_Cap, fec_CycAging_Cap + DOC)/100; % [pu]     
% Correction factor 0.5 necessary to get proper values for resistance increase
agingCalendric.relResistanceChange  = 0.5 * integral(@(FEC)CycAging_Res(abs(avgCRate), DOC, FEC), fec_CycAging_Res, fec_CycAging_Res + DOC,'ArrayValued',true)/100; % [pu]

end
