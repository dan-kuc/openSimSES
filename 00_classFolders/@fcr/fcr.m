%% Class definition: FCR
%   Class definition for object for FCR supply by storage device, based on 
%   energy storage system and grid frequency information.
%   Additionally, IDM transactions, external load and a residential
%   application with energy consumption and generation can be included. 
%
%   2017-01-05 Maik Naumann
%   2019-07-08 Daniel Kucevic
%%
classdef fcr < residential & storage
        
    %%% Properties and arrays to save history of states etc.
    properties(GetAccess = public, SetAccess = private, Hidden = false)
        %% momentary states
        indexIDM
        fcrOutNow                                
        fcrLoadNow                               
        idmLoadNow                            
        residentialLoadNow                       
        externalLoadNow   
    
        %% Properties
        inputFcrProfiles    % FCR, IDM and price profiles
        inputFcr            % Input data for FCR simulations
        pGridExchange       % [W] power exchange with grid
        fcrData             % Struct with all FCR operation data
        resultsEconomicsFcr % Struct with economics results
        resultsTechnicalFcr % Struct with technical results
        pGrid   
        pCurtail
    end

    %%% public methods
    methods
        % constructor
        function ees = fcr( varargin )     
            
            %% parse input and check if input vars are complete
            p = inputParser;
            defVal = NaN;
            
            addParameter(p, 'inputSim',         defVal);
            addParameter(p, 'inputTech',        defVal);
            addParameter(p, 'inputProfiles',    defVal);
            addParameter(p, 'inputForecast',    defVal);
            addParameter(p, 'inputFcr',         defVal);
            addParameter(p, 'inputFcrProfiles', defVal);
            
            parse(p,varargin{:});

            inputSim        = p.Results.inputSim;
            inputTech       = p.Results.inputTech;
            inputProfiles   = p.Results.inputProfiles;
            inputForecast   = p.Results.inputForecast;
            inputFcr        = p.Results.inputFcr;
            inputFcrProfiles= p.Results.inputFcrProfiles;
            
    
             %% call constructor and build object in superclass 
             ees@storage('inputSim',     inputSim,...
                         'inputTech',    inputTech);
            

            %% call constructor and build object in superclass 
            ees@residential('inputSim',     inputSim,...
                            'inputTech',    inputTech,...
                            'inputProfiles',inputProfiles,...
                            'inputForecast',inputForecast);
            
            %% set class specific properties
            setPropertiesFcr(ees, ...
                            'inputFcr',         inputFcr, ...
                            'inputFcrProfiles', inputFcrProfiles);
            
            %% call constructor
            setupImplFcr(ees)
        end
        
        % methods to log power difference between set power and supplied power
        function ees = setPowerDifference( ees, pStorageNow )
            if ees.kNow - 1 <= ees.inputSim.simEnd
                ees.fcrData.fcrPowerDifference(ees.kNow-1) = diff([pStorageNow,-ees.pStorage(ees.kNow-1)]);
            end
        end
        
        %% Declaration of the methods in separate files     
        [ ees ] = runFcrStorage( ees )
        [ ees ] = getFcrLoad( ees )
        [ ees ] = getIdmLoad( ees )    
        [ ees ] = getResidentialLoad( ees )   
        [ ees ] = evalTechnicalFcr( ees )
        [ ees ] = evalEconomicsFcr( ees, varargin )

    end
    
    %%% protected methods
    methods(Access = protected)
        
        function setPropertiesFcr(ees, varargin )
            
        %% parse input and check if input vars are complete
            p = inputParser;
            defVal = NaN;
            
            addParameter(p, 'inputFcr',     defVal);
            addParameter(p, 'inputFcrProfiles',     defVal);
            
            parse(p,varargin{:});
            
            ees.inputFcr            = p.Results.inputFcr;
            ees.inputFcrProfiles    = p.Results.inputFcrProfiles;
        end
        
        %% Common functions
        function setupImplFcr(ees)
      
            % Warning if sample time is chosen to high
            if(ees.inputFcr.flagFcrSupply && ees.inputSim.tSample ~= 1)
                warning(['For FCR simulation sample time has to be 1 second. Chosen sample time is: ', num2str(ees.inputSim.tSample),' s'])
            end
            
            % Start values for simulation variables
            ees.fcrData.indexIDM                            = 1;
            ees.fcrData.fcrOutNow                           = 0;
            ees.fcrData.fcrLoadNow                          = 0;
            ees.fcrData.idmLoadNow                          = 0;
            ees.fcrData.residentialLoadNow                  = 0;
            ees.fcrData.externalLoadNow                     = 0;
           

            % Define number of steps for allocation of state properties
            simulationTime                                  = ees.inputSim.simEnd - ees.inputSim.simStart;
            idmTransactionTimeInterval                      = ees.inputFcr.idmTransactionTimeInterval;

            %% Allocation of variables needed for technical and economic evaluations after storage simulation
            ees.fcrData.fcrPowerDifference                  = zeros(simulationTime,1); % [W] Power which was supplied by storage
            ees.fcrData.idmOut                              = zeros(simulationTime/idmTransactionTimeInterval,1);
            ees.fcrData.dSocIdm                             = zeros(simulationTime/idmTransactionTimeInterval,1);


            if(ees.inputFcr.flagLogFcrResults)
                fcrStepsVector = simulationTime;
            else
                fcrStepsVector = 1;
            end

            % FCR logging variables
            ees.fcrData.fcr30                               = zeros(fcrStepsVector,1); % [W] FCR power of time flexibility degree of freedom
            ees.fcrData.fcrNet                              = zeros(fcrStepsVector,1); % [W] FCR power without considering degrees of freedom
            ees.fcrData.fcrLoad                             = zeros(fcrStepsVector,1); % [W] Resulting FCR power will degrees of freedom applied

            % IDM logging variables
            ees.fcrData.idmLoad                             = zeros(fcrStepsVector,1); % [W] Resulting power of IDM transaction
            

        end % end of init method
    end % methods
end % classdef    
    