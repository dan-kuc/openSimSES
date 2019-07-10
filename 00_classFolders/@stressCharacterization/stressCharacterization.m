%% Class definition: stressCharacterization
% Object type: Matlab object
% Class definition of the stress characterization (SC). 
% The SC is used within the storage simulation object (EES) to characterize 
% the battery stress as required input for the battery aging models.
%
% Call via name-value pair (Example for half-cycle analysis)
% stressCharacterization = stressCharacterization(...
%   'CharacterizationMethod',   @detectHalfCycles, ...
%   'sampleTime',               simParam.sampleTime, ...
%   'SOCThreshold',             10 * 2.2769e-08 * simParam.sampleTime, ... % Threshold of SOC change between two time steps to detect cycle, should be bigger than self discharge
%   'SOCSlopeThreshold',        0.01 * simParam.sampleTime / 60, ... % Threshold of SOC slope change between two 60s time steps to detect cycle: 0.01 = 0.6 C
%   'DOCThreshold',             0, ... % Threshold for the minimum cycle depth that is applied in the half-cycle analysis
%   'evalInitData2beCharacterizedString', '[(1 * EES.simParam.sampleTime),  EES.SOC(1) ];', ...
%   'evalData2beCharacterizedString', '[(((1+EES.stepNow-EES.technicalData.stepSizeStressCharacaterization) : EES.stepNow) * EES.simParam.sampleTime)'',  (EES.SOC((1+EES.stepNow-EES.technicalData.stepSizeStressCharacaterization) : EES.stepNow))'' ];',...
%   'evalLastSimLoopData2beCharacterizedString', '[(((1+EES.stepNow-EES.technicalData.stepSizeStressCharacaterization) : EES.stepNow) * EES.simParam.sampleTime)'',  (EES.SOC((1+EES.stepNow-EES.technicalData.stepSizeStressCharacaterization) : EES.stepNow))'' ];');
%%
% Output:
% - stressCharacterization [-] Object: Object for integration into a storage 
%   object
%
% Input: General
% - CharacterizationMethod [-] String: String to select the method for 
%   stress characerization (See below)
% - sampleTime [s] : Sample time of the storage object simulation
%
% Input: Specific for the 'detectHalfCycles' characterization method
% - SOCThreshold [pu] : Threshold of SOC change between two time steps to 
%   detect cycle, should be bigger than self discharge
% - SOCSlopeThreshold [pu] : Threshold of SOC slope change between two 60s 
%   time steps to detect cycle: 0.01 = 0.6 C
% - DOCThreshold [pu] : Threshold for the minimum cycle depth that is
%   applied in the half-cycle analysis
% - evalInitData2beCharacterizedString [-] : Definition of time and values
%   which are characterized in the first call of stress characerization
% - evalData2beCharacterizedString [-] : Definition of time and values
%   which are characterized in every standard call of stress characerization
% - evalLastSimLoopData2beCharacterizedString [-] : Definition of time and 
%   values which are characterized in the last call of stress characerization
%
% Class definition for the stress characerization as input for the storage
% object (EES). Needs to be created before creating a storage object.
% Different stress characterization methods are available and be
% configured by individual parameters:
% - detectHalfCycles
% 
% 2017-08-04 Naumann/Stückrad
%
%%

classdef stressCharacterization < handle
    
    properties
        Data2beCharacterized                        % matrix with [time, data]
        CharacterizationMethod                      % function call: @CharacterizeWithCountRangePairRangeGradient, @CharacterizeWithCountRangePairRange, @CharacterizeWithCountRange, @CharacterizeWithCountLevelCrossing, @CharacterizeWithCountMeanCrossingPeak, @CharacterizeWithCountPeaksAndThroughs, @CharacterizeWithCountPeak
        sampleTime                                  % Sample time of simulation
        SOCThreshold            = 1e-5;             % Threshold of SOC change between two time steps to detect cycle, should be bigger than self discharge
        SOCSlopeThreshold       = 0.01;             % Threshold of SOC slope change between two 60s time steps to detect cycle: 0.01 = 0.6 C
        DOCThreshold            = 0;                % Threshold for the minimum cycle depth that is applied in the half-cycle analysis
        agingStress                                 % Struct that saves characteristics of detected cycles
        finalSimLoop            = false;
        evalInitData2beCharacterizedString          % String to get Data2beCharacterized in the first simulation step
        evalData2beCharacterizedString              % String to get Data2beCharacterized any further simulation steps, taking into account call frequenzy (how many steps in between 2 calls)
        evalLastSimLoopData2beCharacterizedString   % Sting to get Data2beCharacterized at very last simulation step -> to calculat agin at very last step for sure
    end
    
    methods
        function SC = stressCharacterization(varargin)
            %%% input parsing
            p = inputParser;
            defVal = NaN;
            
            addParameter(p, 'Data2beCharacterized',     defVal);
            addParameter(p, 'CharacterizationMethod',   defVal);
            addParameter(p, 'finalSimLoop',              false);
            addParameter(p, 'evalInitData2beCharacterizedString', defVal);
            addParameter(p, 'evalData2beCharacterizedString', defVal);
            addParameter(p, 'evalLastSimLoopData2beCharacterizedString', defVal);
            addParameter(p, 'SOCThreshold', defVal);
            addParameter(p, 'SOCSlopeThreshold', defVal);
            addParameter(p, 'DOCThreshold', defVal);
            addParameter(p, 'sampleTime', defVal);
            
            parse(p, varargin{:})
            
            SC.Data2beCharacterized    = p.Results.Data2beCharacterized;
            SC.CharacterizationMethod  = p.Results.CharacterizationMethod;
            SC.finalSimLoop            = p.Results.finalSimLoop;
            SC.evalInitData2beCharacterizedString          = p.Results.evalInitData2beCharacterizedString;
            SC.evalData2beCharacterizedString              = p.Results.evalData2beCharacterizedString;
            SC.evalLastSimLoopData2beCharacterizedString   = p.Results.evalLastSimLoopData2beCharacterizedString;
            SC.SOCThreshold            = p.Results.SOCThreshold;
            SC.SOCSlopeThreshold       = p.Results.SOCSlopeThreshold;
            SC.DOCThreshold            = p.Results.DOCThreshold;
            SC.sampleTime              = p.Results.sampleTime;
            
            SC.agingStress.lastCycle(1)    = 1;
            SC.agingStress.idxLogging(1)   = 1;
            SC.agingStress.avgCRate(1)     = 0;
            SC.agingStress.minSOC(1)       = 0;
            SC.agingStress.maxSOC(1)       = 0;
            SC.agingStress.avgCRate(1)     = 0;
            SC.agingStress.avgSOC(1)       = 0;
            SC.agingStress.meanSOC(1)      = 0;
        end
        
        %% Declaration of the methods in separate files      
        [ SC ] = detectHalfCycles( SC )       
    end     
end
      
       

