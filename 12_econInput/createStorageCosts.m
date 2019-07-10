%% createStorageCosts
% Function to generate the storage costs including battery, inverter and
% peripheric elements according to choosen scenario (description: within
% the switch case).
%
% Input == (Parameters)
% scenarioStorageCosts              [-]             string with scenario assumptions of cases below
% KfWRateSubsidy                    [p.u.]          assumed subsidy rate of KfW Bank
%
% Output == (struct)
%   batteryInvestmentCostFixed      [EUR]           Fixed part of battery price
%   batteryInvestmentCostVariable   [EUR / kWh]     Variable part of battery price per kWh
%   inverterInvestmentCostFixed     [EUR]           Fixed part of inverter cost
%   inverterInvestmentCostVariable  [EUR / kW]      Variable part of battery cost per kW
%   storagePeriphericCost           [EUR]           Fixed peripheric costs of storage system
%   storageMaintenanceCost          [EUR / year]    Annual cost for maintenance
%
% 2016-11-16 Maik Naumann
%
%%
function [ inputEconomics ] = createStorageCosts( inputEconomics )

%% use input parameters
scenarioStorageCosts    = inputEconomics.general.scenarioStorageCosts;
depreciationPeriod      = inputEconomics.general.depreciationPeriod;
yearNow                 = inputEconomics.general.yearStart;
yearEnd                 = yearNow + depreciationPeriod - 1;

%% switch case of choosen storage cost scenario
switch lower(scenarioStorageCosts)
    case lower('min')
        % Minimum scenarios for storage prices [2012, 2030]
        % Reference: Technology Overview on Electricity Storage on behalf of SEFEP (2012)
        years      = yearNow:1:yearEnd; 

        % Left: mean value of 2012 storage price ranges
        % Right: mean value of 2030 storage price ranges
        batteryPrice            = [mean([300, 800]), mean([150, 300])]; % [EUR/kWh] Specific costs of storage (SEFEP page 42)
        
        % Left: mean value of 2012 power electronics price ranges
        % Right: mean value of 2030 power electronics price ranges
        pricePowerElectronics   = [mean([150, 200]), mean([35, 65])]; % [EUR/kW] Specific costs of power electronics (SEFEP page 42)
        
        % Assumption of 1.5 percent maintenance costs per year per
        % investment costs
        storageMaintenanceCost  = 0.015; % [1 / (year*investmentCosts)]
        
        % Extrapolate the battery prices between yearsExtrapolation(1) and
        % yearsExtrapolation(end). Each value of the vector represents the
        % price in one year
        batteryPrice            = interp1([2012, 2030],  batteryPrice, years, 'linear', 'extrap');
        pricePowerElectronics   = interp1([2012, 2030],  pricePowerElectronics, years, 'linear', 'extrap');
        
        battInvestCostFix       = 0;                        % [EUR]
        battInvestCostVar       = batteryPrice;             % [EUR/kWh]
        
        inverterInvestCostFix   = 0;                        % [EUR]
        inverterInvestCostVar   = pricePowerElectronics;    % [EUR/kW]
        
        
    %% *_OptimizationPaper
    % Taken from:
    % Hesse, H.C.; Martins, R.; Musilek, P.; Naumann, M.; Truong, C.N.;
    % Jossen, A. Economic Optimization of Component Sizing for Residential
    % Battery Storage Systems. Energies 2017, 10, 835.
    %
    % Cost for power electronics taken from: http://www.photovoltaik4all.de
    % (2016).
    % Battery cost are based on database analysis from pv-magazine (2016).
    % Power electronics cost were substracted from given data.
    case('pbs_optimizationpaper')
        battInvestCostFix       = 1182;     % [EUR]
        battInvestCostVar       = 271;      % [EUR/kWh]
        
        inverterInvestCostFix   = 0;        % [EUR]
        inverterInvestCostVar   = 155;      % [EUR/kW]
        
        storageMaintenanceCost  = 0;
        
    case('lfp_optimizationpaper')
        battInvestCostFix       = 1723;     % [EUR]
        battInvestCostVar       = 752;      % [EUR/kWh]
        
        inverterInvestCostFix   = 0;        % [EUR]
        inverterInvestCostVar   = 155;      % [EUR/kW]
        
        storageMaintenanceCost  = 0;
        
    case('nmc_optimizationpaper')
        battInvestCostFix       = 580;      % [EUR]
        battInvestCostVar       = 982;      % [EUR/kWh]
        
        inverterInvestCostFix   = 0;        % [EUR]
        inverterInvestCostVar   = 155;      % [EUR/kW]
        
        storageMaintenanceCost  = 0;
        
        
    %% tesla_ntpaper
    % Taken from: C. Truong et al., �Economics of Residential Photovoltaic
    % Battery Systems in Germany: The Case of Teslas Powerwall,�
    % Batteries, vol. 2, no. 2, p. 14, 2016.
    case('tesla_ntpaper')
        battInvestCostFix       = 5000;     % [EUR]
        battInvestCostVar       = 0;        % [EUR/kWh]
        
        inverterInvestCostFix   = 0;        % [EUR]
        inverterInvestCostVar   = 0;        % [EUR/kW]
        
        storageMaintenanceCost  = 0;
        
    otherwise
        warning('Chosen storage cost scenario does not exist.')
        
end

disp([mfilename('fullpath') ':'])
disp(['<strong> Storage cost scenario: ', scenarioStorageCosts, '</strong>'])

% Bundle output in struct
inputEconomics.invest.battCostFix       = battInvestCostFix;        % [EUR]
inputEconomics.invest.battCostVar       = battInvestCostVar;        % [EUR/kWh]
inputEconomics.invest.inverterCostFix   = inverterInvestCostFix;    % [EUR]
inputEconomics.invest.inverterCostVar   = inverterInvestCostVar;    % [EUR/kWh]
inputEconomics.general.sysMaintenCost   = storageMaintenanceCost;   % [p.u. / a]

end