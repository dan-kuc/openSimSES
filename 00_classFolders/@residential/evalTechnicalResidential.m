%% evalTechnicalResidential
% Function computes technical values for solar home with and without BESS.
% Energy balance of BESS, household and grid is computed with respective
% self-consumption and self-dependency rates.
%
% Input ==
% ees                   [-] residential class object after simulation
% 
% Output ==
% result                [-] result struct with fields for case with and without BESS
%   loadEnergy          [Ws]    houshehold load
%   generationEnergy    [Ws]    Pv generated energy
%   purchasedEnergy     [Ws]    energy purchased from the grid
%   feedInEnergy        [Ws]    energy fed into grid
%   curtailedEnergy     [Ws]    energy loss caused by curtailment of feed in
%   maxGridLoad         [W]     peak power drawn from grid
%   minGridLoad         [W]     peak power fed into grid
%   selfConsumRate      [pu]    self consumption rate 
%   selfDependRate      [pu]    self dependency rate (self sufficiency rate)
%
% Result of evalTechnical are included in output struct.
%
% 2017-08-08 Nam Truong 
%   2019-05-12 Stefan Englberger
% Update 2019-07-05 Daniel Kucevic
%
%%

function [ ees ] = evalTechnicalResidential( ees )
    % evaluation of technical storage data (application independent)
    result          = evalTechnical( ees );
    
    % ees vars --> local vars
    sampleTime      = ees.inputSim.tSample;
    load            = ees.inputProfiles.load;
    generation      = ees.inputProfiles.genPV;
    gridPower       = ees.powerGrid;
    feedInLimit     = ees.inputTech.power2GridMax(1);

    
    %% household metrics
    % consumption and generation energy
    consumEnergy            = sum( load )       * sampleTime;               % [Ws] household consumption
    genEnergy               = sum( generation ) * sampleTime;               % [Ws] generated energy by generation unit 
    
    
    %% calculate metrics for scenario with BESS
    % energy retrieved from and fed into the grid 
    purchasedPower          =   max(gridPower, 0);                          % [W] power drawn from grid
    feedInPower             = - min(gridPower, 0);                          % [W] power feed-in 
    purchasedEnergy         = sum( purchasedPower )     * sampleTime;       % [Ws] energy bought from the grid 
    feedInEnergy            = sum( feedInPower )        * sampleTime;       % [Ws] energy fed into the grid 
    curtailedEnergy         = sum( ees.powerCurtail )   * sampleTime;       % [Ws] energy lost to curtailment 
    % peak power of grid
    maxGridLoad             = max( gridPower );                             % [W] max. load on grid 
    minGridLoad             = min( gridPower );                             % [W] min. load on grid (infeed) 
    % self-consumption and self-dependency
    selfConsumEnergy        = genEnergy - feedInEnergy;                     % [Ws] self-consumed energy (generated - sold energy)     
    selfDependEnergy        = consumEnergy - purchasedEnergy;               % [Ws] self-supplied load energy (load - purchased energy) 
    selfConsumRate          = selfConsumEnergy / genEnergy;                 % [pu] self-consumption rate 
    selfDependRate          = selfDependEnergy / consumEnergy;              % [pu] self-dependency rate 
    
    
    %% calculate reference values for scenario without BESS
    netLoad                 = load - generation;                            % [W] net load
    noBESSGridPower         = max( netLoad, feedInLimit );                  % [W] power2Grid witohut BESS
    % no ES: energy retrieved from and fed into the grid
    noBESSPurchasePower     =   max(noBESSGridPower, 0);                    % [W] power drawn from grid
    noBESSFeedInPower       = - min(noBESSGridPower, 0);                    % [W] power feed-in 
    noBESSPurchasedEnergy   = sum( noBESSPurchasePower )    * sampleTime;   % [Ws] energy bought from the grid 
    noBESSFeedInEnergy      = sum( noBESSFeedInPower )      * sampleTime;   % [Ws] energy fed into the grid 
    noBESSCurtailedPower    = noBESSGridPower - netLoad;                    % [W] curtailed power
    noBESSCurtailedEnergy   = sum( noBESSCurtailedPower )   * sampleTime;   % [Ws] energy lost to curtailment 
    % no ES: peak power of grid
    noBESSMaxGridLoad       = max( noBESSGridPower );                       % [W] max. load on grid 
    noBESSMinGridLoad       = min( noBESSGridPower );                       % [W] min. load on grid (infeed)
    % no ES: self-consumption and self-dependency
    noBESSSelfConsumEnergy  = genEnergy - noBESSFeedInEnergy;               % [Ws] self-consumed energy (generated - sold energy)     
    noBESSSelfDependEnergy  = consumEnergy - noBESSPurchasedEnergy;         % [Ws] self-supplied load energy (load - purchased energy)
    noBESSSelfConsumRate    = noBESSSelfConsumEnergy / genEnergy;           % [pu] self-consumption rate 
    noBESSSelfDependRate    = noBESSSelfDependEnergy / consumEnergy;        % [pu] self-dependency rate 

    
    %% Write local vars into output struct
    % household load and pv produced energy
    result.solarHome___             = [];
    result.loadEnergy               = consumEnergy;
    result.generationEnergy         = genEnergy;
    
    % grid energy with BESS
    result.residentialBESS___       = [];
    result.purchasedEnergy          = purchasedEnergy;
    result.feedInEnergy             = feedInEnergy;
    result.curtailedEnergy          = curtailedEnergy;
    % grid power with BESS
    result.maxGridLoad              = maxGridLoad;
    result.minGridLoad              = minGridLoad;
    % self consumption and dependency with BESS
    result.selfConsumRate           = selfConsumRate;
    result.selfDependRate           = selfDependRate;
    
    % grid energy wo BESS
    result.residentialNoBESS___     = [];
    result.noBESSPurchasedEnergy    = noBESSPurchasedEnergy;
    result.noBESSFeedInEnergy       = noBESSFeedInEnergy;
    result.noBESSCurtailedEnergy    = noBESSCurtailedEnergy;
    % grid power wo BESS
    result.noBESSMaxGridLoad        = noBESSMaxGridLoad;
    result.noBESSMinGridLoad        = noBESSMinGridLoad;
    % self consumption and dependency wo BESS
    result.noBESSSelfConsumRate     = noBESSSelfConsumRate;
    result.noBESSSelfDependRate     = noBESSSelfDependRate;
    
    ees.resultsTechnical = result;
    
end

