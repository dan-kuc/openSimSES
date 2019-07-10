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
%   Update: 2019-07-08 Daniel Kucevic
%%

function inputTech = techParamStdPVHomeStorage()
global gvarYEARS2SECONDS gvarDAYS2SECONDS gvarKWH2WS

%% PV system
inputTech.pPVnom        = 4.4*1e3;              % [W]
inputTech.rCurtPV       = 0.6;                  % [pu] ratio of installed PVpeak to be curtailed for feed-in: 0.6 with KfW subsidy, 0.7 in general
inputTech.rAgingPV      = 0.5/100;              % [pu] aging per year

%% load
inputTech.eAnnLoad          = 4400 * gvarKWH2WS;    % [Ws]

inputTech.tPersistFCload    = 0;                    % [s] time period of shifting load profiles (persistant forecast)
inputTech.tPersistFCPV      = 0;                    % [s] time period of shifting load profiles (persistant forecast)

%% storage
% batteryType:          options for battery types are listed in '/03_SimulationInput/createBatteryData.m'
% agingModelType:       available aging models are listed in '/03_SimulationInput/createAgingModel.m'
% combAgingFct:         functions that combine calendric and cycle aging are located in /03_SimulationInput/combAgingType
% cycleDetectionType:   options for cycle detection method are listed in '/@storage/detectStress.m'  
inputTech.eBattNom      = 4.4 * gvarKWH2WS;                     % [Ws] single value or array
inputTech.voltBattNom   = 650;                                  % [V] desired nominal voltage of battery system --> depending on battery type (EC-model) according # of cells in series with new nominal voltage
inputTech.soc0          = 0.5;                                  % [pu] initial SOC at starting step
inputTech.socLimLow     = 0;                                    % [pu] lower SOC limit
inputTech.socLimHigh    = 1;                                    % [pu] upper SOC limit
inputTech.sohCap0       = 1;                                    % [pu] initial SOH of storage capacity
inputTech.sohRes0       = 1;                                    % [pu] initial SOH of storage resistance
inputTech.typeBatt      = 'clfp_sony_us26650_experiment_ocv_r'; % battery type for operation parameters 
inputTech.typeAgingMdl  = 'clfp_sony_us26650_experiment';       % aging model 

% Parameters for stress detection method.
inputTech.stepSzStressCharact   = 10;            % [~] Step size for calling of stress characterization
inputTech.stepSzCalAging        = 10;            % [~] Step size for calling of calendar aging model 
inputTech.stepSzCycAging        = 10;            % [~] Step size for calling of cycle aging model (should be smaller or equal to stepSizeStressCharacterization)


%% Type of thermal model
% TODO: Couple thermal model with selection of setPowerStorage function
inputTech.fctThermMdl       = @battModel_thermalCell;

%% power electronics
% powerElectronicsMethod:   efficiency curves given in '/03_SimulationInput/createPowerElectronicsData.m'
inputTech.pInverterNom      = 4.4 * 1000 ;         % rated power of battery inverter [W]
inputTech.inverterP_0       = 0.0072;              % parameter for 'Formula'
inputTech.inverterK         = 0.0345;              % parameter for 'Formula'
inputTech.inverterEta       = 0.95;                % parameter for 'constant' --> currently not used!
inputTech.inverterMethod    = 'formula';           % expected parameters: 'constant','Formula','Array'
inputTech.inverterNumber    = 2;                   % Number of inverters for modular operation
inputTech.inverterSwitch    = 0.8;                 % Switch-Value of inverters for modular operation [P/Pmax]
inputTech.etaAccuracy       = 200;                 % array size for efficiency determination in simulation



%% choose OS
inputTech.osStorage         = @OSPVHomeGreedy;

% Enviromental parameters
inputTech.temperatureAmbient    = 25 + 273.15;          % [K] temporary constant value
inputTech.pStorageOp            = 0;                    % [W] power consumption required to operate storage device (sensors, controller, thermal management)     
            
%% Define storage replacement values
% Get replacement data for setReplacement method
inputTech.replaceParam      = createBatteryReplacementData('Generic'); % Struct with replacement data
% Set specific replacement interval or schedule next replacement
inputTech.schedulReplace    = 0; % [s] Absolute time for first storage replacement after simulation start. Set to zero if no replacement is desired.
inputTech.tReplace          = 0; % [s] Time interval for storage replacements after first replacement. Set to zero if no replacement is desired.

end