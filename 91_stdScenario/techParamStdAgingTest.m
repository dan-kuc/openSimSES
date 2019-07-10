%% Function for standard PV-home battery case Germany
% Script to create technical parameters for standard case of residential 
% storage system in Germany for self-consumption increase of households.
%
%   PV kWp          4.4     kW      
%   load            4,500   kWh/a
%   battery size    4.4     kWh
%
%   battery power   4.4     kW
%   PV curtailment  0.7     p.u.
%   PV aging        0.005   p.u./a
%   batt SOC limit  [0, 1]  p.u.
%   batt init SOC   0       p.u.
%   PE efficiency   equation according to SCHMID J., et. al.
%
%   battery aging   
%       measurements        baseLine scenario derived from Rosenkranz with
%                           higher cycle life
%   	stress detection    Half-cycle detection
%       combination         superposition of calendric and cyclical aging
%       init value SOH      0 p.u.
%
% Function to be called in calling script of simulation of residential
% storage systems. Recommendation is to build standard parameterset and
% alter the created values, if necessary.
% Fieldname of struct generated in this function needs to be maintained for
% the object access the correct values.
%
% Nam Truong 2017-08-07
%%

function technicalData = techParamStdPVHomeStorage()
global gvarYEARS2SECONDS gvarDAYS2SECONDS gvarKWH2WS

%% PV system
technicalData.PVPeakPower               = 4.4*1e3;              % [W]
technicalData.PVCurtailment             = 1;                  % [pu] ratio of installed PVpeak to be curtailed for feed-in: 0.6 with KfW subsidy, 0.7 in general
technicalData.PVagingPerYear            = 0/100;              % [pu] aging per year

%% load
technicalData.annualLoad                = 4400 * gvarKWH2WS;        % [Ws]
technicalData.persistancePeriodLoad     = 0;                    % [s] time period of shifting load profiles (persistant forecast)
technicalData.persistancePeriodPV       = 0;                    % [s] time period of shifting load profiles (persistant forecast)

%% storage
% batteryType:          options for battery types are listed in '/03_SimulationInput/createBatteryData.m'
% agingModelType:       available aging models are listed in '/03_SimulationInput/createAgingModel.m'
% combAgingFct:         functions that combine calendric and cycle aging are located in /03_SimulationInput/combAgingType
% cycleDetectionType:   options for cycle detection method are listed in '/@storage/detectStress.m'  
technicalData.batteryNominalEnergy      = 4.4 * gvarKWH2WS;         % [Ws] single value or array
technicalData.batteryNominalVoltage     = 51.2;                 % [V] desired nominal voltage of battery system --> depending on battery type (EC-model) according # of cells in series with new nominal voltage
technicalData.startSOC                  = 0.5;                    % [pu] initial SOC at starting step
technicalData.SOCLimLow                 = 0;                    % [pu] lower SOC limit
technicalData.SOCLimHigh                = 1;                    % [pu] upper SOC limit
technicalData.sohCapacityStart          = 1;                    % [pu] initial SOH of storage capacity
technicalData.sohResistanceStart        = 1;                    % [pu] initial SOH of storage resistance
technicalData.batteryType               = 'clfp_sony_us26650_experiment';     % battery type for operation parameters 
technicalData.agingModelType            = 'clfp_sony_us26650_experiment';     % aging model 

% Parameters for stress detection method.
technicalData.stepSizeStressCharacterization    = 1;            % [~] Step size for calling of stress characterization
technicalData.stepSizeCalendarAging             = 1;            % [~] Step size for calling of calendar aging model 
technicalData.stepSizeCycleAging                = 1;            % [~] Step size for calling of cycle aging model (should be smaller or equal to stepSizeStressCharacterization)

% Generate object _stressCharacterization_ to detect the stress inflicted
% on the batteries.
technicalData.callMethodAgingModels     = @callMethodAgingModels_SingleValues;  % Function for the different method and strategies of calling the aging calculation -> see stepsToStartAgingFct

%% Type of thermal model
% TODO: Couple thermal model with selection of setPowerStorage function
technicalData.thermalModelFunction      = @fThermalCell;

%% power electronics
% powerElectronicsMethod:   efficiency curves given in '/03_SimulationInput/createPowerElectronicsData.m'
technicalData.powerElectronicsRatedPower = 10 * 1000 ;         % rated power of battery inverter [W]
technicalData.powerElectronicsMethod    = 'constant';            % expected parameters: 'constant','Formula','Array'
technicalData.powerElectronicsP_0       = 0.0072;               % parameter for 'Formula'
technicalData.powerElectronicsK         = 0.0345;               % parameter for 'Formula'
technicalData.powerElectronicsEta       = 1;                 % parameter for 'constant' --> currently not used!

technicalData.etaAccuracy               = 1000;                 % array size for efficiency determination in simulation

%% choose OS
technicalData.storageOS                 = @OSPVHomeGreedy;

% Enviromental parameters
technicalData.temperatureAmbient        = 25 + 273.15;          % [K] temporary constant value

%% Define storage replacement values
% Get replacement data for setReplacement method
[inputTech.replacementData]         = createBatteryReplacementData('Generic'); % Struct with replacement data
% Set specific replacement interval or schedule next replacement
inputTech.scheduledNextReplacement  = 0; % [s] Absolute time for first storage replacement after simulation start. Set to zero if no replacement is desired.
inputTech.replacementInterval       = 0; % [s] Time interval for storage replacements after first replacement. Set to zero if no replacement is desired.

end