%% 1.3.2 / 1.3.3 (island grid scenario) +++ allocateEconomicsSheet()
% 
% allocates raw input data from excel sheet to technical input structs
% 
% INPUT
%   rawInputData    input cell matrix from excel sheet containing the data
%                   in raw form
%   scenario        chosen application scenario so that function knows
%                   which data to read and write
% 
% OUTPUT
%   inputEconomics  struct containing economic parameters
%   2019-07-05 Daniel Kucevic
% 
%% 

function [inputEconomics] = allocateEconomicsSheet(rawInputData, scenario)

valuesFromSheet     = rawInputData(:,2);
sheetDataGeneral    = valuesFromSheet(2:5);
sheetDataStorage    = valuesFromSheet(8:10);

%% General data
inputEconomics.general.interestRate         = sheetDataGeneral{1} / 100;                     % [-] interest rate p.a.
inputEconomics.general.inflationRate        = sheetDataGeneral{2} / 100;                     % [-] inflation rate p.a.
inputEconomics.general.depreciationPeriod   = sheetDataGeneral{3};                           % [a] depreciation period
inputEconomics.general.yearStart            = sheetDataGeneral{4};

%% Storage data
inputEconomics.general.scenarioStorageCosts = sheetDataStorage{1};  % expected scenarios or battery choice: 'Max' ,'Min',...
inputEconomics.invest.sysAuxCompCostFix     = sheetDataStorage{2};  % [EUR]
inputEconomics.general.installCost          = sheetDataStorage{3};  % [EUR] installation cost

end

