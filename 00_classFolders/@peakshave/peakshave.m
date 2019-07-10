%% Peak Shaving
%
%   Class definition for objectobject for PS supply by storage device, based on 
%   energy storage system.
%
%   2019-05-12 Stefan Englberger
% Update 2019-07-05 Daniel Kucevic
%%
classdef peakshave < storage
    
    %%% Properties and arrays to save history of states etc.
    properties (GetAccess = public, SetAccess = private, Hidden = false)
        %% Input data
        inputPSProfiles       % load  profile stored in object
        inputPSForecast       % forecast of profiles stored in object and changeable
        
        %% Properties
        pPSGrid                       % [W] Power drawb from power
        resultsPSTechnical            % struct with technical results
        resultsPSTechnicalAnnual      % struct with technical results
        inputPSEconomics              % struct with economic parameters
        resultsPSEconomics            % struct with economics results
    end
    
  %%% public methods
    methods
        % constructor
        function ees = peakshave( varargin )
                        
            %% parse input and check if input vars are complete
            p = inputParser;
            defVal = NaN;
            
            addParameter(p, 'inputSim',     defVal);
            addParameter(p, 'inputTech',    defVal);
            addParameter(p, 'inputProfiles',     defVal);
            addParameter(p, 'inputForecast',     defVal);
            
            parse(p,varargin{:});

            inputSim        = p.Results.inputSim;
            inputTech       = p.Results.inputTech;
            inputPSProfiles   = p.Results.inputProfiles;
            inputPSForecast   = p.Results.inputForecast;
            
            %% call constructor and build object in superclass 
             ees@storage('inputSim',     inputSim,...
                        'inputTech',    inputTech);
            
            
            %% set class specific properties
            setPropertiesPeakShave(ees, ...
                            'inputProfiles', inputPSProfiles, ...
                            'inputForecast', inputPSForecast);
            
        end
        
           % methods to change forecast ofter creation of object
        function ees = setLoadPSForecast( ees, loadFC ) 
            ees.inputForecast.load       = loadFC;   % set new forecast profile
        end
     
        % methods to hand over input for economic evaluations
        function ees = setInputPSEconomics( ees, inputEconomics ) 
            ees.inputEconomics       = inputEconomics;   % set new inputEconomics
        end
        
        %% Declaration of the methods in separate files     
        [ ees ] = runPSStorage( ees )
        [ ees ] = evalTechnicalPeakShave( ees )
%         [ ees ] = evalAnnualTechResidential( ees )
%         [ ees ] = evalEconomics( ees, varargin )
    end
    
    %%% protected methods
    methods(Access = protected)
        
        function setPropertiesPeakShave(ees, varargin )
            
            %% parse input and check if input vars are complete
            p = inputParser;
            defVal = NaN;
            
            addParameter(p, 'inputProfiles',     defVal);
            addParameter(p, 'inputForecast',     defVal);
            
            parse(p,varargin{:});
            
            ees.inputPSProfiles   = p.Results.inputProfiles;
            ees.inputPSForecast   = p.Results.inputForecast;
        end
    end % methods
    
end


