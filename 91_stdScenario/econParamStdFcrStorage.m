%% Function for standard FCR storage case Germany
% Script to create economic parameters for standard case of FCR storage system in Germany 
%
%   electricity price       increase for electricity price based on extrapolation of 2004-2014 price: BDEW, Bundesnetzagentur for household with 3.500 kWh/year
%   storage price           average LFP price according to market (Q1 17)
%   subsidy rate            0.22 p.u. of system price subsidized
%   feed in remuneration    12.56 ct/kWh
%   interest rate           0.04 p.u.
%   inflation rate          0.02 p.u.
%   depreciation perediod   20 a
%   installation cost       0 p.u. of system price
%
% Function to be called in calling script of simulation of FCR
% storage systems. Recommendation is to build standard parameterset and
% alter the created values, if necessary.
% Fieldname of struct generated in this function needs to be maintained for
% the object access the correct values.
%
% 04.01.2018 Maik Naumann


function [ inputEconomics ] = econParamStdFcrStorage(  )

% scenarioElectricityPrices:    electricity price scenarios specified in '/03_SimulationInput/createElectricityPrices.m'
% scenarioStorageCosts:         development of battery costs are specified in '/03_SimulationInput/createStorageCosts.m'    
inputEconomics.general.scenarioStorageCosts = 'LFP_OptimizationPaper';  % expected scenarios or battery choice: 'Max' ,'Min',... 
inputEconomics.general.interestRate         = 0.04;                     % [-] interest rate p.a.
inputEconomics.general.inflationRate        = 0.02;                     % [-] inflation rate p.a.
inputEconomics.general.depreciationPeriod   = 20;                       % [a] depreciation period
inputEconomics.general.installCost          = 0;                        % [EUR] installation cost
inputEconomics.general.yearStart            = 2017;                     % [-] date in which simulation starts

inputEconomics.pvHome.feedInRemuneration          = 0.1256;             % EUR / kWh 
inputEconomics.pvHome.scenarioElectricityPrices   = 'extrapolmeangrowth'; % scenarios in 02_Scenarios/createElectricityPrices.m
inputEconomics.pvHome.scenarioFeedInRemuneration  = 'constant';         % scenarios: 'constant'    
inputEconomics.pvHome.investSubsidy               = 0.25;               % [p.u.] KfW subsidy for Q1/2015

end

