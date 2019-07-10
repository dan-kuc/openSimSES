%% Residential
%
%   Class definition for object with generation, consumption and storage
%   device. Based on ees residential consumer with PV-unit and energy storage system.
%   Uses system object storage for computation. Additional fields to model
%   the system with PV and load. Profiles are included in object.
%   Equivalent to building simulink model.
%
%   2018-01-05 Naumann/Truong
% Update 2019-07-05 Daniel Kucevic
%%
classdef residential < storage
    
    %%% Properties and arrays to save history of states etc.
    properties (GetAccess = public, SetAccess = private, Hidden = false)
        %% Input data
        inputProfiles       % load and generation profile stored in object
        inputForecast       % forecast of profiles stored in object and changeable
        inputEconomics      % struct with economic parameters SimSES_neu
        
        %% Properties
        powerGrid                   % [W] power drawn from grid
        powerCurtail                % [W] curtailed power
        resultsTechnical            % struct with technical results
        resultsTechnicalAnnual      % struct with technical results
        %SimSES_alt       
        %inputEconomics             % struct with economic parameters
        resultsEconomics            % struct with economics results
    end

    %%% public methods
    methods
        % constructor
        function ees = residential( varargin )
                        
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
            inputProfiles   = p.Results.inputProfiles;
            inputForecast   = p.Results.inputForecast;
            
            %% call constructor and build object in superclass 
            ees@storage(... 
                            'inputSim',     inputSim,...
                            'inputTech',    inputTech);
            
            %% set class specific properties
            setPropertiesResidential(ees, ...
                            'inputProfiles', inputProfiles, ...
                            'inputForecast', inputForecast);
            
        end
        
        % methods to change forecast ofter creation of object
        function ees = setLoadForecast( ees, loadFC ) 
            ees.inputForecast.load       = loadFC;   % set new forecast profile
        end
        function ees = setGenerationForecast( ees, genFC ) 
            ees.inputForecast.generation = genFC;    % set new forecast profile
        end
        
        % methods to hand over input for economic evaluations
        function ees = setInputEconomics( ees, inputEconomics ) 
            ees.inputEconomics       = inputEconomics;   % set new inputEconomics
        end
        
        %% Declaration of the methods in separate files     
        [ ees ] = runStorage( ees )
        [ ees ] = evalTechnicalResidential( ees )
        [ ees ] = evalAnnualTechResidential( ees )
        [ ees ] = evalEconomics( ees, varargin )
        fcProfile = get_clear_sky_prediction(ees, kLookAhead)
        fcProfile = getClearSkyEPrediction(ees, kLookAhead)
    end
    
    %%% protected methods
    methods(Access = protected)
        
        function setPropertiesResidential(ees, varargin )
            
            %% parse input and check if input vars are complete
            p = inputParser;
            defVal = NaN;
            
            addParameter(p, 'inputProfiles',     defVal);
            addParameter(p, 'inputForecast',     defVal);
            
            parse(p,varargin{:});
            
            ees.inputProfiles   = p.Results.inputProfiles;
            ees.inputForecast   = p.Results.inputForecast;
        end
    end % methods
end % classdef