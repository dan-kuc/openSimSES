%% calculateStorageCosts 
% Function calculates the storage costs (investment and replacement costs)
% per year.
% Called by evalEconomics method.
%
% INPUT: 
%   EES: storage object from simulation
%   inputEconomics: struct that contains prices of storage e.g. battery,
%       inverter, variable and fix costs, maintenance, peripheric ...
% OUTPUT:
%   costsStorage: struct containing costs of storage (invest, replacement,
%       maintenance)
% 
% Markus F�rstl 

function [ storageCost ] = calculateStorageCosts( ees, varargin )

global gvarYEARS2SECONDS gvarKWH2WS

%% Prepare input data
if nargin > 1
    econParams  = varargin{1};
else
    econParams  = ees.inputEconomics;
end

% simulationYears     = ees.inputSim.simEnd / gvarYEARS2SECONDS;
% depreciationPeriod  = min(ees.inputEconomics.general.depreciationPeriod, simulationYears);  % Depreciation time cannot be longer than simulation time. Unit: years
% depreciationPeriod  = max(floor(depreciationPeriod), 1);                                    % at least one year
tDepreciation   = econParams.general.depreciationPeriod;
econInvest      = econParams.invest;

%% Calculate Investment Costs
% battery investment
battSizekWh     = ees.inputTech.eBattNom / gvarKWH2WS;  % battery size [kWh]
battCostkWh     = econInvest.battCostVar * battSizekWh;       % size dependent battery cost
investBatt      = econInvest.battCostFix + battCostkWh;
% inverter investment
invSizekW       = ees.inputTech.pInverterNom / 1000;  % rated power inverter [kW]
invCostkW       = econInvest.inverterCostVar * invSizekW;     % size dependent inverter cost
investInverter  = econInvest.inverterCostFix + invCostkW;
% installation cost of system
installCost     = econParams.general.installCost; 
% total investment cost
investTotal     = investBatt + investInverter + installCost; 

%% Replacement Costs 
maintenanceCost     = econParams.general.sysMaintenCost .* investTotal(1);  % annual maintenance cost
maintenanceCashFlow = repmat( maintenanceCost, tDepreciation, 1);              % cashflow over all years
replacementYear     = false(tDepreciation,1);

% Convert points in time of replacement to respective years in depreciation periods
for idxStorageReplacement = 1:numel(ees.storageReplacement)
    replacementYear(max(floor(ees.storageReplacement(idxStorageReplacement) * ees.inputSim.tSample / gvarYEARS2SECONDS),1)) = true;
end

% if battery price-timeseries is greater than/equal depreciationPeriod
if length(investBatt) >= tDepreciation 
    replacementCost = investBatt(1:tDepreciation)' .* replacementYear; 
% if investBattSum is a scalar
elseif length(investBatt) == 1 
    replacementCost = investBatt .* replacementYear; 
end

%% Total Storage Costs
% Broken down approach as of now bc investment costs need to be handled
% separately
storageCost.invest      = investTotal(:); 
storageCost.replacement = replacementCost(:); 
storageCost.maintenance = maintenanceCashFlow(:); 

end

