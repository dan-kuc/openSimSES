%% Function for standard FCR case in Germany
%   Script to create technical parameters for standard case of FCR 
%   storage system in Germany including a PV system and external load.
%
%   Function to be called in calling script of simulation of FCR
%   storage systems. Recommendation is to build standard parameterset and
%   alter the created values, if necessary.
%   Fieldname of struct generated in this function needs to be maintained for
%   the object access the correct values.
%
%   2018-09-13 Daniel Kucevic
%   Update: 2019-07-08 Daniel Kucevic
%%
function [inputTech, inputFcr] = techParamStdFcrStorage()
global gvarKWH2WS

%% PV system
inputTech.pPVnom            = 4.4*1e3;              % [W]
inputTech.rCurtPV           = 0.6;                  % [pu] ratio of installed PVpeak to be curtailed for feed-in: 0.6 with KfW subsidy, 0.7 in general
inputTech.rAgingPV          = 0.5/100;              % [pu] aging per year

%% load
inputTech.eAnnLoad          = 4400 * gvarKWH2WS;    % [Ws]
inputTech.tPersistFCload    = 0;                    % [s] time period of shifting load profiles (persistant forecast)
inputTech.tPersistFCPV      = 0;                    % [s] time period of shifting load profiles (persistant forecast)

%% storage
% batteryType:          options for battery types are listed in '/03_SimulationInput/createBatteryData.m'
% agingModelType:       available aging models are listed in '/03_SimulationInput/createAgingModel.m'
% combAgingFct:         functions that combine calendric and cycle aging are located in /03_SimulationInput/combAgingType
% cycleDetectionType:   options for cycle detection method are listed in '/@storage/detectStress.m'  
inputTech.eBattNom      = 5e3 * gvarKWH2WS;                 % [Ws] single value or array
inputTech.voltBattNom   = 51.2;                             % [V] desired nominal voltage of battery system --> depending on battery type (EC-model) according # of cells in series with new nominal voltage
inputTech.soc0          = 0.5;                              % [pu] initial SOC at starting step
inputTech.socLimLow     = 0;                                % [pu] lower SOC limit
inputTech.socLimHigh    = 1;                                % [pu] upper SOC limit
inputTech.sohCap0       = 1;                                % [pu] initial SOH of storage capacity
inputTech.sohRes0       = 1;                                % [pu] initial SOH of storage resistance
inputTech.typeBatt      = 'clfp_sony_us26650_experiment';   % battery type for operation parameters 
inputTech.typeAgingMdl  = 'clfp_sony_us26650_experiment';   % aging model 

% Parameters for stress detection method.
inputTech.stepSzStressCharact   = 60*10;            % [~] Step size for calling of stress characterization
inputTech.stepSzCalAging        = 60*10;            % [~] Step size for calling of calendar aging model 
inputTech.stepSzCycAging        = 60*10;            % [~] Step size for calling of cycle aging model (should be smaller or equal to stepSizeStressCharacterization)

%% Type of thermal model
% TODO: Couple thermal model with selection of setPowerStorage function
inputTech.fctThermMdl      = @battModel_thermalCell;

%% power electronics
% powerElectronicsMethod:   efficiency curves given in '/03_SimulationInput/createPowerElectronicsData.m'
inputTech.pInverterNom      = 4e6 ;                % rated power of battery inverter [W]
inputTech.inverterMethod    = 'constant';      % expected parameters: 'constant','Formula','Array'
inputTech.etaAccuracy       = 200;                 % array size for efficiency determination in simulation

% Enviromental parameters
inputTech.temperatureAmbient    = 25 + 273.15;          % [K] temporary constant value
inputTech.pStorageOp            = 0;                    % [W] power consumption required to operate storage device (sensors, controller, thermal management)     
            
%% Define storage replacement values
% Get replacement data for setReplacement method
inputTech.replaceParam      = createBatteryReplacementData('Generic'); % Struct with replacement data
% Set specific replacement interval or schedule next replacement
inputTech.schedulReplace    = 0; % [s] Absolute time for first storage replacement after simulation start. Set to zero if no replacement is desired.
inputTech.tReplace          = 0; % [s] Time interval for storage replacements after first replacement. Set to zero if no replacement is desired.

%% FCR simulation data
inputFcr.power2EnergyRatio      = 0.7;      % [pu] power to energy ratio
inputFcr.idcTimeWait            = 2.7;      % [-] Wait factor for IDC transactions
inputFcr.idcPowerFactor         = 4.2;      % [-] Power factor for IDC transactions
inputFcr.idcPowerLimitFactor    = 0.5;      % [-] Power factor to limit IDC transactions
inputFcr.idcPriceSell           = 74;       % [€/MWh] IDC arbitrage case: Price limit to sell energy (value according to MA Felix Kiefl for prices of 2014)
inputFcr.idcPriceBuy            = 3;        % [€/MWh] IDC arbitrage case: Price limit to buy energy (value according to MA Felix Kiefl for prices of 2014)
inputFcr.flagFcrSupply          = true;     % If true storage is operated to supply FCR
inputFcr.flagIdcTransactions    = true;     % If true storage is operated with IDC transactions
inputFcr.flagIdcConservative    = false;    % If true storage is operated with IDC transactions to be always within the valid range
inputFcr.flagIdcArbitrage       = false;    % If true storage is operated with IDC transactions to exploit arbitrage
inputFcr.flagIdcWorstCase       = false;    % If true worst case scenario is applied with always IDC buying transactions
inputFcr.flagExternalLoad       = false;    % If true external load is used for SOC optimization
inputFcr.flagResidential        = false;    % If true residential residual load is added to storage usage
inputFcr.flagNewRegulations     = true;     % Else old / standard regulations with 30 minutes criteria

%% available storage OS
inputFcr.storageOS              = @OSFcr;
end