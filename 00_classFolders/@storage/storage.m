%% Class definition: storage
% Object type: Matlab object
% Class definition simulation of storage. The model includes operational
% limits (SOC, power), losses and aging.
%
% Call via name-value pair
% ees = storage('inputSim', inputSim, 'inputTech', inputTech, 'economicData', economicData)
%
% Output:
% - ees: object for simulation
%
% Input:
% - inputSim: struct with simulation parameters in respective struct-fields
% - inputTech: struct with technical parameters of the storage system 
%   and its aux. components.
% - economicData: struct with economic input data of storage system
%
% Class definition for simulation of storage system.
% 
% Operational limits (SOC and power) are checked within setPower method and
% do not require consideration in the control algorithm.
% Object states are updated after reference power is given. Submodels for
% aging, aux. components, battery are used for computation of state
% changes.
%
%   2017-08-04 Naumann/Truong
%
% Properties in storage were extended for multi-use strategies and the compensation of reactive power.
%   2019-05-12 Stefan Englberger
% Update 2019-07-05 Daniel Kucevic


classdef storage < handle

    %%% Properties and arrays to save history of states etc.
    properties (GetAccess = public, SetAccess = protected, Hidden = false)
        %% Input data
        inputSim                % Input parameter struct for simulation configuration of storage object
        inputTech               % Input parameter struct for technical configuration of storage object
    end
    
    properties (GetAccess = public, SetAccess = public, Hidden = false)
        %% BESS states
        % momentary states
        pStorageNow             % [W] Current visible power of ES at inverter terminal (connection to grid) (charging positive, discharging negative)
        pStorageFtmNow          % [W] Current visible power of ES at inverter terminal in multi-use case (connection to grid) (charging positive, discharging negative)
        pStorageBtmNow          % [W] Current visible power of ES at inverter terminal in multi-use case (connection to grid) (charging positive, discharging negative)
        pBattNow                % [W] Current power seen by battery at terminal / DC-side of inverter
        pStorageOpNow           % [W] Current power consumption required to operate storage device (sensors, controller, thermal management)
        qAvailableNow           % [var] current available reactive power at inverter terminal
        qCompNow                % [var] current compensated reactive power 
        socNow                  % [pu] current SOC
        
        tNow                    % [s] Time since start of simulation
        kNow                    % [~] Steps since start of simulation
        cosWOCompNow            % [rad] Cosinus before compensation of reactive power
        cosWithCompNow          % [rad] Cosinus after compensation of reactive power

        % history of states
        pStorage                % [W] visible power of ES at inverter terminal (connection to grid) (charging positive, discharging negative) 
        pStorageFtm             % [W] visible power of ES at inverter terminal in multi-use case (connection to grid) (charging positive, discharging negative) 
        pStorageBtm             % [W] visible power of ES at inverter terminal in multi-use case (connection to grid) (charging positive, discharging negative) 
        pBatt                   % [W] power seen by battery at terminal
        pLossInv                % [W] losses due to inverter
        pLossBatt               % [W] losses in battery
        qAvailable              % [var] Available reactive power at inverter terminal
        qComp                   % [var] Compensated reactive power
        eLossSelfDis            % [Ws] loss due to self discharge
        soc                     % [pu] state of charge
        socLimHigh              % [pu] upper SOC limit --> tunable for some EMS
        socLimLow               % [pu] lower SOC limit
        cellStates              % [-] Struct for logging of output values of battery EC model
        temperature             % [K] Battery temperature
        cosWOComp               % [rad] Cosinus before compensation of reactive power
        cosWithComp             % [rad] Cosinus after compensation of reactive power        
        
        % parameters
        setPStorage = @(x) [];  % Function handle to determine how SOC etc. is handled (EC or power flow)
        etaBatt                 % efficiency curve of battery
        etaInverter             % efficiency curve of inverter
        etaInverterInv          % inverse efficiency curve of inverter
        
        % auxilliary states and profiles
        pStorageOp              % [W] power consumption required to operate storage device (sensors, controller, thermal management)
        tSampleNow              % [s] sample time of current step
        
        %% Aging 
        % momentary states
        sohCapNow                               % [pu] Current SOH of storage capacity
        sohResNow                               % [pu] Current SOH of storage resistance
        
        totalRelCapacityChangeCalendricNow      % [Ws] capacity change due to calendric aging
        totalRelCapacityChangeCyclicNow         % [Ws] capacity change due to cycle aging
        totalRelCapacityChangeNow               % [Ws] capacity change due to calendric and cycle aging
        totalRelResistanceChangeCalendricNow    % [Ohm] resistance change due to calendric aging
        totalRelResistanceChangeCyclicNow       % [Ohm] resistance change due to cycle aging
        totalRelResistanceChangeNow             % [Ohm] resistance change due to calendric and cycle aging
        lastStateVectorUpdateTimeNow            % [s] time of last state vector update 
    
        % arrays to save history of states etc.
        stressCharacterization      % stress characterization model
        storageReplacement          % [bool] time vector of storage replacements after EOL has been reached
        agingStress                 % [-] struct that saves detected cycles [cycleDepth, cRate, lastCycleEndStep]
        sohCap                      % [pu] SOH of storage capacity
        sohRes                      % [pu] SOH of storage resistance
        capacityChangeCalendric     % [Ws] capacity change due to calendric aging
        capacityChangeCyclic        % [Ws] capacity change due to cycle aging
        capacityChangeTotal         % [Ws] capacity change due to calendric and cycle aging
        resistanceChangeCalendric   % [Ohm] resistance change due to calendric aging
        resistanceChangeCyclic      % [Ohm] resistance change due to cycle aging
        resistanceChangeTotal       % [Ohm] resistance change due to calendric and cycle aging
    end
    
    properties (Dependent)
        capBattNow
    end
    
    methods
        
        %% Constructor to create EES object of class storage
        function ees = storage( varargin )
            % constructor
            setProperties(ees, varargin{:});  
            setupImpl(ees)
        end
        
        %% run object for one step
        function [pStorage, socNow, sohCapNow] = step(ees, pIn, tSim, varargin)
            % Update times and calculate storage action only if time step > 0
            ees.tSampleNow  = max(tSim - ees.tNow, 0);
            ees.tNow        = tSim;

            % Update power states if storage capacity is still available
            if ( ees.sohCapNow > 0.001)
                ees = ees.setPStorage(ees, pIn);
            else
                % Set default values
                ees.SOCnow      = 0;                
                ees.pStorageNow = 0;        
                ees.pBattNow    = 0;  
            end
            
            %% compute battery stress and resulting aging
            if ees.inputTech.callAging
                if nargin < 4 || strcmpi(varargin{1}, 'run')
                    characterizeStress( ees );
                    calcAging( ees ); 
                end
                % Check whether storage replacement takes place:
                if ( ees.sohCapNow < ees.inputTech.agingMdl.remainCapacityEOL )
                    setReplacement( ees );
                end

            end
            
            %% storage replacement
            % With configured replacement interval
            if( ees.inputTech.schedulReplace ~= 0 && tSim > ees.inputTech.schedulReplace)
                setReplacement( ees );
                % Determine next replacement time with configured replacement interval
                ees.inputTech.schedulReplace = tSim + ees.inputTech.tReplace;
            end      

            ees.lastStateVectorUpdateTimeNow    = tSim;
            ees.kNow                            = ees.kNow + 1;

            
            % Update output values
            pStorage    = ees.pStorageNow;
            socNow      = ees.socNow;
            sohCapNow   = ees.sohCapNow;
        end
              
        %% function to set SOC limits
        function [ ees ] = setSOClim( ees, newSOClim )
            if numel(newSOClim)==2
                if(newSOClim(2) > 1)
                    error('SOClimHigh should be below 1')
                else
                    ees.SOClimHigh = newSOClim(2);         % upper SOC limit
                end
            
                if(newSOClim(1) < 0)
                    error('SOClimLow should be above 0')
                else
                    ees.SOClimLow = newSOClim(1);          % lower SOC limit
                end
            else
                warning('SOC limit setting requires 2 values.')
            end
        end
        
        %% function to reset SOC limits to initial value
        function [ ees ] = resetSOClim( ees )
            ees.socLimLow   = ees.inputTech.SOClimLow;
            ees.socLimHigh  = ees.inputTech.SOClimHigh;
        end
        
        %% function to obtain current energy capacity of battery
        function val = get.capBattNow(ees)
            val = ees.SOHcapNow * ees.inputTech.eBattNom;
        end
        
        % method required for dependend property
        function set.capBattNow(ees, ~)
        end
        
        %% Declaration of the methods in separate files  
        ees = deepCopyObj(ees)
        
%     end
% 
%     methods(Access = protected)
        % Set input properties
        function setProperties(ees, varargin)
            
            %% parse input and check if input vars are complete
            p = inputParser;
            defVal = NaN;

            addParameter(p, 'inputSim',     defVal);
            addParameter(p, 'inputTech',    defVal);

            parse(p,varargin{:});

            ees.inputSim    = p.Results.inputSim;
            ees.inputTech   = p.Results.inputTech;
        end
        
        % initialize object with parameters at first step
        function setupImpl(ees)
            
            if ~isfield(ees.inputSim,'objCopy') || ~ees.inputSim.objCopy
                % Set setPowerStorage method
                ees.setPStorage = ees.inputTech.setPStorageMethod;  % set fhandle as setPowerStorage method

                % Adapt battery rated power to power electronics rated
                % power 
                if isempty(ees.inputTech.etaInverter) %TODO DO we want this here?
                    ees.inputTech.pBattNom = ees.inputTech.pInverterNom / ees.inputTech.etaInverter_Ch(end); 
                else
                    ees.inputTech.pBattNom = ees.inputTech.pInverterNom / ees.inputTech.etaInverter(end); 
                end
                %% Create eta as efficiency curves
                % Creates array with efficiency of power electronics (determines powerBatt)
                setupEtaPowerElectronics( ees );       
                % Creates array with efficiency of battery (determines dSOC)
                setupEtaBatt( ees );                                        

                % Initialize simulation time states
                ees.tSampleNow = 0;
                ees.tNow = 0;
                ees.kNow = 1;
                ees.lastStateVectorUpdateTimeNow = 0;

                % Initialize battery states           
                ees.pStorageNow     = 0;
                ees.pStorageOpNow   = 0;
                ees.pBattNow        = 0;
                ees.socNow              = ees.inputTech.soc0;   % start SOC

                if(ees.inputTech.socLimHigh > 1)
                    error('socLimHigh should be below 1')
                else
                    ees.socLimHigh = ees.inputTech.socLimHigh;  % upper SOC limit
                end

                if(ees.inputTech.socLimLow < 0)
                    error('socLimLow should be above 0')
                else
                    ees.socLimLow = ees.inputTech.socLimLow;    % lower SOC limit
                end

                ees.sohCapNow   = ees.inputTech.sohCap0;        % start SOH of storage capacity
                ees.sohResNow   = ees.inputTech.sohRes0;        % start SOH of storage resistance
                ees.pStorageOp  = ees.inputTech.pStorageOp;     % [W] power consumption required to operate storage device (sensors, controller, thermal management)     

                ees.totalRelCapacityChangeCalendricNow      = 0;    % [Ws] capacity change due to calendric aging
                ees.totalRelCapacityChangeCyclicNow         = 0;    % [Ws] capacity change due to cycle aging
                ees.totalRelCapacityChangeNow               = 0;    % [Ws] capacity change due to calendric and cycle aging
                ees.totalRelResistanceChangeCalendricNow    = 0;    % [Ohm] resistance change due to calendric aging
                ees.totalRelResistanceChangeCyclicNow       = 0;    % [Ohm] resistance change due to cycle aging
                ees.totalRelResistanceChangeNow             = 0;    % [Ohm] resistance change due to calendric and cycle aging

                % Define number of steps for allocation of state properties
                simStepsVector   = zeros(1,ceil((ees.inputSim.simEnd - ees.inputSim.simStart)/ees.inputSim.tSample));          

                % Allocation of battery states
                ees.pStorage            = simStepsVector; % [W] visible power of ES at inverter terminal (connection to grid) (charging positive, discharging negative) 
                ees.pBatt               = simStepsVector; % [W] power seen by battery at terminal
                ees.pLossInv            = simStepsVector; 
                ees.pLossBatt           = simStepsVector; 
                ees.eLossSelfDis        = 0; 
                ees.soc                 = simStepsVector + ees.socNow; % [pu] state of charge
                ees.sohCap              = simStepsVector + ees.sohCapNow; % [pu] SOH of storage capacity
                ees.sohRes              = simStepsVector + ees.sohResNow; % [pu] SOH of storage resistance
                ees.temperature         = simStepsVector + ees.inputTech.temperatureAmbient; % [K] Battery temperature
                ees.storageReplacement  = []; % [bool] time vector of storage replacements after EOL has been reached

                % Allocation of battery cell states 
                if(ees.inputSim.flagLogBattEc && strcmp(func2str(ees.inputTech.setPStorageMethod), 'setPowerStorageEquivalentCircuit'))                                                                    
                    storageEcOutputStepsVector = simStepsVector;
                else
                    storageEcOutputStepsVector = 0;                                                            % If logging is deactivated, no value of battery EC model is logged
                end

                ees.cellStates          = struct( ...                   % [-] Struct for logging of output values of battery EC model
                                            'powerLoss', storageEcOutputStepsVector, ...
                                            'voltage',   storageEcOutputStepsVector, ...
                                            'current',   storageEcOutputStepsVector, ...
                                            'eta',       storageEcOutputStepsVector, ...
                                            'ocv',       storageEcOutputStepsVector, ...
                                            'ri',        storageEcOutputStepsVector);

                

                % If aging should be neglected with agingModelType 'noaging',
                % noAging is forced to be selected for aging stress
                % characterization and aging calculation
                if(strcmp(ees.inputTech.typeAgingMdl, 'no aging'))
 %                   disp([mfilename ': noAging is selected as aging model type: ', ...
 %                           'No stress characterization is executed and no aging is calculated']);
                    ees.inputTech.callAging = false;
                    % Select NoAging as method to be called inside callAging method
                    ees.inputTech.callMethodAgingModels = @callMethodAgingModels_noAging;

                    % Select NoAging as method to be called when calculating total aging
                    % inside the callMethodAgingModels method
                    ees.inputTech.combAgingFct          = @combAgingType_noAging;

                    % Logging of aging is deactivated if no aging is selected
                    ees.inputSim.flagLogAging        = false;
                else
                    ees.inputTech.callAging = true;
                % Create stress characterization object
                    ees.stressCharacterization   = stressCharacterization( ...
                                        'CharacterizationMethod',   ees.inputTech.stressCharactParams.CharacterizationMethod, ...
                                        'sampleTime',               ees.inputTech.stressCharactParams.sampleTime, ...
                                        'SOCThreshold',             ees.inputTech.stressCharactParams.SOCThreshold,  ... % Threshold of SOC change between two time steps to detect cycle, should be bigger than self discharge
                                        'SOCSlopeThreshold',        ees.inputTech.stressCharactParams.SOCSlopeThreshold, ... % Threshold of SOC slope change between two 60s time steps to detect cycle: 0.01 = 0.6 C
                                        'DOCThreshold',             ees.inputTech.stressCharactParams.DOCThreshold, ... % Threshold for the minimum cycle depth that is applied in the half-cycle analysis
                                        'evalInitData2beCharacterizedString', ees.inputTech.stressCharactParams.evalInitData2beCharacterizedString, ...
                                        'evalData2beCharacterizedString', ees.inputTech.stressCharactParams.evalData2beCharacterizedString,...
                                        'evalLastSimLoopData2beCharacterizedString', ees.inputTech.stressCharactParams.evalLastSimLoopData2beCharacterizedString);
                end
                
                
                % Allocation of battery aging trends
                if(ees.inputSim.flagLogAging)                                                                    
                    agingStepsVector = simStepsVector;
                else
                    agingStepsVector = 0; % logging is deactivated, only last value of aging is logged
                end
                
                % Initialize battery aging operation states
                ees.capacityChangeCalendric             = agingStepsVector;
                ees.capacityChangeCyclic                = agingStepsVector;
                ees.capacityChangeTotal                 = agingStepsVector;
                ees.resistanceChangeCalendric           = agingStepsVector;
                ees.resistanceChangeCyclic              = agingStepsVector;
                ees.resistanceChangeTotal               = agingStepsVector;

                ees.agingStress.lastCycle               = agingStepsVector;
                ees.agingStress.avgCRate                = agingStepsVector;
                ees.agingStress.avgSOC                  = agingStepsVector;
                ees.agingStress.meanSOC                 = agingStepsVector;
                ees.agingStress.minSOC                  = agingStepsVector;
                ees.agingStress.maxSOC                  = agingStepsVector;

                % Initialize battery aging initial states
                ees.agingStress.avgSOC(1)                   = ees.inputTech.soc0;
                ees.agingStress.lastCycle(1)                = 1; 
                ees.agingStress.cumAgingTime                = 0;
                ees.agingStress.cumRelCapacityThroughput    = 0;    
            end
        end

        %% Declaration of the methods in separate files  
        % construction methods
        [ ees ] = setupEtaBatt( ees )
        [ ees ] = setupEtaPowerElectronics( ees )
        % operation methods
        [ ees ] = setReplacement( ees )
        % aging methods
        [ ees ] = characterizeStress ( ees )
        [ ees ] = calcAging ( ees )
        
    end  
end % classdef