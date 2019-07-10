%% createTechParamPVHomeStorage
% Script that calls necessary sub scripts (preprocessing of data) for
% inputProfiles and scenarios.
% Necessary functions to generate more complex input data.
%
% Function to be called in main simulation script after one-value
% parameters (technical and simulation) are set.
%
% 2017-07-27 Truong
%%

% calculate max grid feed-in based on curtailment rule of PV Peak
inputTech.power2GridMax             = [- inputTech.PVPeakPower * inputTech.PVCurtailment, inf]; % negative value for feedin limit [W]

% generate efficiency curve of inverter
[inputTech.powerElectronicsEta]     = createPowerElectronicsData( ...
                                        'powerElectronicsMethod',   inputTech.powerElectronicsMethod, ...
                                        'powerElectronicsP_0',      inputTech.powerElectronicsP_0, ...
                                        'powerElectronicsK',        inputTech.powerElectronicsK, ...
                                        'powerElectronicsEta',      inputTech.powerElectronicsEta);

% generate battery parameters
[inputTech.etaBatt,                 ...
 inputTech.selfDischargeRate,       ...
 inputTech.batteryNominalVoltage,   ...
 inputTech.batteryNominalEnergy,    ...
 inputTech.SOCLimLow,               ...
 inputTech.SOCLimHigh,              ...   
 inputTech.batteryModelParameters,  ...
 inputTech.setPowerStorageMethod]   = createBatteryData( ...
                                        'batteryType',              inputTech.batteryType, ...
                                        'batteryNominalVoltage',    inputTech.batteryNominalVoltage, ...
                                        'batteryNominalEnergy',     inputTech.batteryNominalEnergy);

% generate aging model
[inputTech.agingModel, ...
 inputTech.combAgingFct]            = createAgingModel( ...
                                        'agingModelType', inputTech.agingModelType);

% generate stress characterization object
inputTech.stressCharacterizationOptions    = struct( ...
                                    'CharacterizationMethod',   @detectHalfCycles, ...
                                    'sampleTime',               inputSim.sampleTime, ...
                                    'SOCThreshold',             10 * 2.2769e-08 * inputSim.sampleTime,  ... % Threshold of SOC change between two time steps to detect cycle, should be bigger than self discharge
                                    'SOCSlopeThreshold',        0.01 * inputSim.sampleTime / 60,        ... % Threshold of SOC slope change between two 60s time steps to detect cycle: 0.01 = 0.6 C
                                    'DOCThreshold',             0.00, ... % Threshold of DOC change to detect cycle
                                    'evalInitData2beCharacterizedString', '[(1 * EES.inputSim.sampleTime),  EES.SOC(1) ];', ...
                                    'evalData2beCharacterizedString', '[(((1+EES.stepNow-EES.inputTech.stepSizeStressCharacterization) : EES.stepNow) * EES.inputSim.sampleTime)'',  (EES.SOC((1+EES.stepNow-EES.inputTech.stepSizeStressCharacterization) : EES.stepNow))'' ];',...
                                    'evalLastSimLoopData2beCharacterizedString', '[(((1+EES.stepNow-EES.inputTech.stepSizeStressCharacterization) : EES.stepNow) * EES.inputSim.sampleTime)'',  (EES.SOC((1+EES.stepNow-EES.inputTech.stepSizeStressCharacterization) : EES.stepNow))'' ];');
                                                                                                                                                                            
% generate generation profile
inputProfiles.generation            = createProfiles( ...
                                        'profile',          generationProfile, ...
                                        'profilePeak',      inputTech.PVPeakPower, ...
                                        'sampleTime',       inputSim.sampleTime, ...
                                        'simPeriod',        [inputSim.simStart,inputSim.simEnd], ...
                                        'profilePeriod',    inputSim.genProfileLength);

% include aging in generation profile
inputProfiles.generation            = agingPV( ...
                                        'simTime',          inputSim.simEnd,...
                                        'PVProfile',        inputProfiles.generation,...
                                        'PVagingPerYear',   inputTech.PVagingPerYear);
                   
% generate load profile
inputProfiles.load                  = createProfiles( ...
                                        'profile',          loadProfile, ...
                                        'profilePeak',      inputTech.PVPeakPower, ...
                                        'sampleTime',       inputSim.sampleTime, ...
                                        'simPeriod',        [inputSim.simStart,inputSim.simEnd], ...
                                        'profilePeriod',    inputSim.loadProfileLength);

% generate persistant inputForecast for PV
inputForecast.generation            = generatePersistantForecast (  ...
                                        'persistancePeriod',    inputTech.persistancePeriodPV,...
                                        'profile',              inputProfiles.generation,...
                                        'sampleTime',           inputSim.sampleTime);
                                    
% generate persistant inputForecast for load
inputForecast.load                  = generatePersistantForecast (  ...
                                        'persistancePeriod',    inputTech.persistancePeriodLoad,...
                                        'profile',              inputProfiles.load,...
                                        'sampleTime',           inputSim.sampleTime);