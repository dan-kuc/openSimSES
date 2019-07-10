%% 1.3.1 +++ allocateTechSheet()
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
%   inputTech       struct containing technical parameters
%   inputFcr        struct containing fcr parameters (optional, only for fcr and/or
%                   scr simulation
%
%   2019-07-05 Daniel Kucevic
%%

function [inputTech, varargout] = allocateTechSheet(rawInputData, scenario)
%% Get raw data and categorize it
valuesFromSheet     = rawInputData(:,2);
sheetDataBatt       = valuesFromSheet(2:15);
sheetDataInv        = valuesFromSheet(18:25);
sheetDataPVRes      = valuesFromSheet(28:33);
sheetDataStressDet  = valuesFromSheet(36:39);
sheetDataStorageRep = valuesFromSheet(41:42);
sheetDataFcr        = valuesFromSheet(45:52);


%% Battery data
inputTech.eBattNom                      = sheetDataBatt{1} * 3600e3;    % [Ws]
inputTech.voltBattNom                   = sheetDataBatt{2};             % [V]
inputTech.soc0                          = sheetDataBatt{3} / 100;       % [p.u.]
inputTech.socLimLow                     = sheetDataBatt{4} / 100;       % [p.u.]
inputTech.socLimHigh                    = sheetDataBatt{5} / 100;       % [p.u.]
inputTech.sohCap0                       = sheetDataBatt{6} / 100;       % [p.u.]
inputTech.sohRes0                       = sheetDataBatt{7} / 100;       % [p.u.]
inputTech.pStorageOp                    = sheetDataBatt{8};             % [W]
inputTech.temperatureAmbient            = sheetDataBatt{9} + 273.15;    % [K]
inputTech.typeBatt                      = lower(sheetDataBatt{10});
inputTech.typeAgingMdl                  = lower(sheetDataBatt{11});

inputTech.agingMdl.remainCapacityEOL    = sheetDataBatt{12} / 100;
inputTech.fctThermMdl                   = str2func(sheetDataBatt{13});

inputTech.osStorage                     = str2func(sheetDataBatt{14}); % operation strategy
        

%% Power Electronics
inputTech.pInverterNom      = sheetDataInv{1} * 1000;   % [W]
inputTech.etaAccuracy       = sheetDataInv{2};          %
inputTech.inverterMethod    = lower(sheetDataInv{3});   % 'constant' or 'formula' or 'Siemens Sinamics' % Added by Anupam on 25.01.2019
inputTech.inverterEta       = sheetDataInv{4};          % parameter for 'constant' --> currently not used!
inputTech.inverterP_0       = sheetDataInv{5};          % parameter for 'Formula'
inputTech.inverterK         = sheetDataInv{6};          % parameter for 'Formula'
inputTech.inverterNumber    = sheetDataInv{7};          % Number of inverters for modular operation
inputTech.inverterSwitch    = sheetDataInv{8};          % Switch-Value of inverters for modular operation [P/Pmax]

%% PV Residential

inputTech.pPVnom                = sheetDataPVRes{1} * 1000;     % [W]
inputTech.rCurtPV           = sheetDataPVRes{2} / 100;      % [pu] ratio of installed PVpeak to be curtailed for feed-in: 0.6 with KfW subsidy, 0.7 in general
inputTech.rAgingPV              = sheetDataPVRes{3} / 100;      % [pu] aging per year

inputTech.eAnnLoad                  = sheetDataPVRes{4} * 3600e3;       % [Ws]
inputTech.tPersistFCload            = sheetDataPVRes{5};                % [s  time period of shifting load profiles (persistant forecast)

if strcmp(scenario, 'residential pv-battery system') || strcmp(scenario, 'fcr')
    inputTech.tPersistFCPV          = sheetDataPVRes{6};            % [s] time period of shifting PV profiles (persistant forecast)
end

%% Parameters for stress detection method
inputTech.stepSzStressCharact       = sheetDataStressDet{1}; % [~] Step size for calling of stress characterization
inputTech.stepSzCalAging            = sheetDataStressDet{2}; % [~] Step size for calling of calendar aging model
inputTech.stepSzCycAging            = sheetDataStressDet{3}; % [~] Step size for calling of cyclic aging model

%% Storage replacement
inputTech.schedulReplace            = sheetDataStorageRep{1}; % [s] Absolute time for first storage replacement after simulation start. Set to zero if no replacement is desired.
inputTech.tReplace                  = sheetDataStorageRep{2}; % [s] Time interval for storage replacements after first replacement. Set to zero if no replacement is desired.


%% FCR
if strcmp(scenario, 'fcr')
    inputFcr.power2EnergyRatio      = sheetDataFcr{1};      % [pu] power to energy ratio
    inputFcr.idmTimeWait            = sheetDataFcr{2};      % [-] Wait factor for IDM transactions
    inputFcr.idmPowerFactor         = sheetDataFcr{3};      % [-] Power factor for IDM transactions
    inputFcr.idmPowerLimitFactor    = sheetDataFcr{4};      % [-] Power factor to limit IDM transactions
    inputFcr.flagLogFcrResults      = sheetDataFcr{5};      % If true all output values of fcr simulation are logged
    inputFcr.flagFcrSupply          = sheetDataFcr{6};      % If true storage is operated to supply FCR
    inputFcr.flagIdmTransactions    = sheetDataFcr{7};      % If true storage is operated with IDM transactions
    inputFcr.flagNewRegulations     = sheetDataFcr{8};     % Else old / standard regulations with 30 minutes criteria
    varargout{1}                    = inputFcr;
end

end

