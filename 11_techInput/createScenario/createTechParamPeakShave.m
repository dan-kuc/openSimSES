%% createTechParamPsStorage
% Script that calls necessary sub scripts (preprocessing of data) for
% inputProfiles and scenarios.
% Necessary functions to generate more complex input data.
%
% Function to be called in main simulation script after one-value
% parameters (technical and simulation) are set.
%
%   2019-05-12 Stefan Englberger
%   Update: 2019-07-08 Daniel Kucevic
%%

% generate efficiency curve of inverter
[inputTech.etaInverter, inputTech.etaInverter_Ch, inputTech.etaInverter_Dis] = createPowerElectronicsData( ...
    'inverterMethod',   inputTech.inverterMethod, ...
    'inverterP_0',      inputTech.inverterP_0, ...
    'inverterK',        inputTech.inverterK, ...
    'inverterEta',      inputTech.inverterEta, ...
    'inverterNumber',   inputTech.inverterNumber, ...
    'inverterSwitch',   inputTech.inverterSwitch, ...
    'voltBattNom',      inputTech.voltBattNom, ...
    'etaAccuracy',      inputTech.etaAccuracy);


% generate battery parameters
[inputTech.etaBatt,                 ...
 inputTech.rSelfDischarge,          ...
 inputTech.voltBattNom,             ...
 inputTech.eBattNom,                ...
 inputTech.socLimLow,               ...
 inputTech.socLimHigh,              ...   
 inputTech.battMdlParams,  ...
 inputTech.setPStorageMethod]     = createBatteryData( ...
                                        'typeBatt',              inputTech.typeBatt, ...
                                        'voltBattNom',           inputTech.voltBattNom, ...
                                        'eBattNom',              inputTech.eBattNom, ...
                                        'socLimLow',             inputTech.socLimLow, ...
                                        'socLimHigh',            inputTech.socLimHigh);

% generate aging model
[inputTech.agingMdl, ...
 inputTech.combAgingFct,    ...
 inputTech.callFctAgingMdl  ]      = createAgingModel( ...
                                        'typeAgingMdl', inputTech.typeAgingMdl);

% generate stress characterization object
inputTech.stressCharactParams      = struct( ...
                                    'CharacterizationMethod',   @detectHalfCycles, ...
                                    'sampleTime',               inputSim.tSample, ...
                                    'SOCThreshold',             10 * 2.2769e-08 * inputSim.tSample,  ... % Threshold of SOC change between two time steps to detect cycle, should be bigger than self discharge
                                    'SOCSlopeThreshold',        0.01 * inputSim.tSample / 60,        ... % Threshold of SOC slope change between two 60s time steps to detect cycle: 0.01 = 0.6 C
                                    'DOCThreshold',             0, ...
                                    'evalInitData2beCharacterizedString', '[(1 * ees.inputSim.tSample),  ees.soc(1) ];', ...
                                    'evalData2beCharacterizedString', '[(((1+ees.kNow-ees.inputTech.stepSzStressCharact) : ees.kNow) * ees.inputSim.tSample)'',  (ees.soc((1+ees.kNow-ees.inputTech.stepSzStressCharact) : ees.kNow))'' ];',...
                                    'evalLastSimLoopData2beCharacterizedString', '[(((1+ees.kNow-ees.inputTech.stepSzStressCharact) : ees.kNow) * ees.inputSim.tSample)'',  (ees.soc((1+ees.kNow-ees.inputTech.stepSzStressCharact) : ees.kNow))'' ];');
                                                                                                                                                                            
% generate load profile
inputProfiles.load                  = createProfiles( ...
                                        'profile',          inputTech.loadProfile, ...
                                        'pPeakProfile',     inputTech.pPeak, ...  
                                        'tSample',          inputSim.tSample, ...
                                        'tSim',             [inputSim.simStart,inputSim.simEnd], ...
                                        'tProfile',         inputSim.loadProfileLength);