%% createAgingModel
% Function to return aging model struct during parameter-setting phase of
% main simulation. Struct will be used to instantiate storage object and
% the aging model parameters are determined.
%
% agingModel = createAgingModel('param','value')
%
% Input == (parameters)
% agingModelType    [-]     string with chosen aging model
%
% Output ==
% agingModel        [-]     Returns aging model of choosen technology:
%   # Lib_Rosenkranz
%   # CLFP_Goebel
%   # NMC_Tesla_DailyCyclePowerwall
%   # CLFP_Sony_US26650_Experiment
%   # VRF_Battery (ZAE)
%   # NoAging
%   # Dummy
%   # C/NMC IHR18650A Molicel
%
% Switch case below is chosen with input parameter and the according
% parameters are set.
%
% 2017-08-08   Maik Naumann
%   Update: 2019-07-08 Daniel Kucevic
%
%%

function [ agingModel, combAgingFct, callFctAgingMdl ] = createAgingModel( varargin )

%% Input parsing
p = inputParser;    % generate parsing handle
defVal = NaN;       % set def value for parsing
% add parameter accepted for input
addParameter(p, 'typeAgingMdl', defVal);
% parse input
parse(p, varargin{:})
% write parsed input into local var
typeAgingMdl     = p.Results.typeAgingMdl;

%% Configuration values for stress characterization 
agingModel.remainCapacityEOL    = 0.6;  % If % of E_N is reached SoH = 0% -> Battery replacement
agingModel.DOCThresh            = 0.01; % Threshold for the minimum cycle depth that is considered with the aging model

% Empty struct fields to avoid errors in later functions (parser)
agingModel.calAgingCapFct  = [];
agingModel.calAgingResFct  = [];
agingModel.cycAgingCapFct  = [];
agingModel.cycAgingResFct  = [];

% Generate object _stressCharacterization_ to detect the stress inflicted
% on the batteries.
callFctAgingMdl   = @callMethodAgingModels_AverageValues;  % Function for the different method and strategies of calling the aging calculation -> see stepsToStartAgingFct


%% Switch case for aging function selection
switch lower(typeAgingMdl)
    %% LiB_Rosenkranz
    % Weak aging case for paper:
    %
    %   Naumann, Maik; Truong, Cong Nam; Karl, Ralph Ch; Jossen, Andreas; 
    %       Energiespeichertechnik, Elektrische (2014): Betriebsabhängige 
    %       kostenberechnung von energiespeichern. In: 13. Symposium 
    %       Energieinnovation. Graz, S. 1–16.
    case('lib_rosenkranz') 
        agingModel.remainCapacityEOL        = 0.8;                          % If 80% of E_N is reached SoH = 0% -> Battery replacement
        agingModel.DOCThresh                = 0.01;                         % Threshold for the minimum cycle depth that is considered with the aging model
        % set calendric and cyclic aging models (fhandles)
        agingModel.calAgingFct  = @LiB_Rosenkranz_CalAging;
        agingModel.cycAgingFct  = @LiB_Rosenkranz_CycAging;
        
        combAgingFct            = @combAgingType_Superposition;             % Function for combination of battery aging factors 
        
        
    %% CLFP_Goebel
    % Aging data and model according to paper:
    %
    %   Goebel, C.; Hesse, H. et al. (2016): Model-based Dispatch Strategies 
    %       for Lithium-Ion Battery Energy Storage applied to Pay-as-Bid 
    %       Markets for Secondary Reserve. In: IEEE Trans. Power Syst., 
    %       S. 1. DOI: 10.1109/TPWRS.2016.2626392.
    case('clfp_goebel') 
        agingModel.remainCapacityEOL    = 0.8;                              % If 80% of E_N is reached SoH = 0% -> Battery replacement
         agingModel.DOCThresh           = 0.01;                             % Threshold for the minimum cycle depth that is considered with the aging model
        % set calendric and cyclic aging models (fhandles)
        agingModel.calAgingFct  = @CLFP_Goebel_CalAging;
        agingModel.cycAgingFct  = @CLFP_Goebel_CycAging;
        
        combAgingFct            = @combAgingType_Maximum;                   % Function for combination of battery aging factors 

        
    %% NMC_Tesla_DailyCyclePowerwall
    % NMC_Tesla_DailyCyclePowerwall aging data is fitted on data of Tesla 
    % DailyCycle Powerwall warranty sheet.
    case('nmc_tesla_dailycyclepowerwall')      
        agingModel.remainCapacityEOL        = 0.6;                          % If 80% of E_N is reached SoH = 0% -> Battery replacement
        agingModel.DOCThresh                = 0.01;                         % Threshold for the minimum cycle depth that is considered with the aging model
        
        % set calendric and cyclic aging models (fhandles)
        agingModel.calAgingFct  = @NMC_Tesla_DailyCyclePowerwall_CalAging;
        agingModel.cycAgingFct  = @NMC_Tesla_DailyCyclePowerwall_CycAging; 
        
        combAgingFct            = @combAgingType_CyclicOnly;                % Function for combination of battery aging factors 

        
    %% LFP/C_SONY_US26650_Experiment
    % LFP/C_SONY_US26650_Experiment aging model consists of a calendar and
    % pure cycle aging model parametrized with long lasting aging studies
    % and validated with dynamic profiles 
    % DailyCycle Powerwall warranty sheet.
    case('clfp_sony_us26650_experiment')      
        agingModel.remainCapacityEOL        = 0.0;                          % If 80% of E_N is reached SoH = 0% -> Battery replacement
        agingModel.DOCThresh                = 0.01;                         % Threshold for the minimum cycle depth that is considered with the aging model
        
        agingFunctions = load('CLFP_Sony_US26650_Experiment_AgingModels.mat');
        
        % set calendric and cyclic aging models (fhandles)
        agingModel.calAgingFct = @CLFP_Sony_US26650_Experiment_CalAging;
        agingModel.cycAgingFct = @CLFP_Sony_US26650_Experiment_CycAging;  
        
        % set calendric and cyclic aging models
        agingModel.calAgingCapFct = agingFunctions.qloss_cal;
        agingModel.calAgingResFct = agingFunctions.rinc_cal;
        agingModel.cycAgingCapFct = agingFunctions.qloss_cyc;
        agingModel.cycAgingResFct = agingFunctions.rinc_cyc;
        
        % set calendric and cyclic time/FEC index function
        agingModel.calAgingCapFctIndex = agingFunctions.time_qloss_cal;
        agingModel.calAgingResFctIndex = agingFunctions.time_rinc_cal;
        agingModel.cycAgingCapFctIndex = agingFunctions.fec_qloss_cyc;
        agingModel.cycAgingRecFctIndex = agingFunctions.fec_rinc_cyc;
        
        combAgingFct            = @combAgingType_Superposition;              % Function for combination of battery aging factors           
            
    
    %% VRF_Battery (ZAE)
    case('vrf_battery') 
        agingModel.remainCapacityEOL        = 0.8;                          % If 80% of E_N is reached SoH = 0% -> Battery replacement
        agingModel.DOCThresh                = 0.01;                         % Threshold for the minimum cycle depth that is considered with the aging model
        % set calendric and cyclic aging models (fhandles)
        agingModel.calAgingFct  = @VRF_Battery_CalAging;
        agingModel.cycAgingFct  = @noAgingFct;
        
        combAgingFct            = @combAgingType_Superposition;             % Function for combination of battery aging factors 
                
    %% C/NMC Molicel IHR18650A
    % based on ageing model of C/NMC Molicel IHR18650A cells developed at EES/TUM 
    case('cnmc_molicel_ihr_18650a_ageing') 
        agingModel.remainCapacityEOL        = 0.5;                          % If 80% of E_N is reached SoH = 0% -> Battery replacement
        agingModel.DOCThresh                = 0.01;                         % Threshold for the minimum cycle depth that is considered with the aging model
        % load ageing factor matrix for ageing calculation
        load('CNMC_Molicel_CA_cal.mat');
        load('CNMC_Molicel_CA_cyc.mat');
        load('CNMC_Molicel_Ri_cal.mat');
        load('CNMC_Molicel_Ri_cyc.mat');
        
        agingModel.k_ca_cal = stressfactor_CA;  
        agingModel.k_ca_cyc = Stressfactor_CA_cycle;
        agingModel.k_ri_cal = stressfactor_Rtotal_calendric; 
        agingModel.k_ri_cyc = pure_cyclic_stressfactor_Rtotal;
        
        agingModel.index_soc                   = 0:0.01:1;
        agingModel.index_T                     = 10:1:50;
        agingModel.index_DOD                   = 0:0.001:1;
        
        % set calendric and cyclic aging models (fhandles)
        agingModel.calAgingFct  = @NMC_Molicel_IHR18650A_CalAging;
        agingModel.cycAgingFct  = @NMC_Molicel_IHR18650A_CycAging; 
        
        combAgingFct            = @combAgingType_Superposition;                % Function for combination of battery aging factors         
        
    %% NoAging
    % Case for simulations without aging (improved speed)
    case('no aging')
        agingModel.remainCapacityEOL    = 0.6;                              % If 80% of E_N is reached SoH = 0% -> Battery replacement
        agingModel.DOCThresh            = 0.01;                             % Threshold for the minimum cycle depth that is considered with the aging model
        % set calendric and cyclic aging models (fhandles)
        agingModel.calAgingFct  = @noAgingFct;
        agingModel.cycAgingFct  = @noAgingFct;
        
        combAgingFct            = @combAgingType_noAging;                   % Function for combination of battery aging factors 
        callFctAgingMdl         = @callMethodAgingModels_noAging;
        
    %% default
    % error for invalid input
    otherwise
        error([mfilename('fullpath') ': No battery aging model specified.'])
end

% show chosen method in command window.
disp([mfilename ': <strong>', typeAgingMdl, '</strong>'])

end

