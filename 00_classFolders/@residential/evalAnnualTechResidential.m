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
%
%%

function [ ees ] = evalAnnualTechResidential( ees )

global gvarYEARS2SECONDS gvarDAYS2SECONDS gvarKWH2WS
    % evaluation of technical storage data (application independent)
    result          = evalTechnical( ees );
    
    % ees vars --> local vars
    tSample     = ees.inputSim.sampleTime;
    load        = ees.inputProfiles.load;
    generation  = ees.inputProfiles.generation;
    pGrid       = ees.powerGrid;
    feedInLimit = ees.inputTech.power2GridMax(1);
    nYears      = ceil( ees.inputSim.simEnd / gvarYEARS2SECONDS );
    
    % annual profiles
    annLoad     = reshape( load(:)      , [], nYears);
    annGen      = reshape( generation(:), [], nYears);
    annPGrid    = reshape( pGrid(:) , [], nYears);
    annPCurtail = reshape( ees.powerCurtail(:), [], nYears);
    
    %% household metrics
    % consumption and generation energy
    eConsum     = sum( load )       * tSample;               % [Ws] household consumption
    eGen        = sum( generation ) * tSample;               % [Ws] generated energy by generation unit 
    
    %% annual household metrics
    % annual values
    annEConsum  = sum( annLoad )    .* tSample;
    annEGen     = sum( annGen )     .* tSample;
    
    %% calculate metrics for scenario with BESS
    % energy retrieved from and fed into the grid 
    pPurchase   =   max( pGrid, 0 );                    % [W] power drawn from grid
    pFeedIn     = - min( pGrid, 0 );                    % [W] power feed-in 
    ePurchase   = sum( pPurchase )          * tSample;  % [Ws] energy bought from the grid 
    eFeedIn     = sum( pFeedIn )            * tSample;  % [Ws] energy fed into the grid 
    eCurtailed  = sum( ees.powerCurtail )   * tSample;  % [Ws] energy lost to curtailment 
    % peak power of grid
    maxPGrid    = max( pGrid );                         % [W] max. load on grid 
    minpGrid    = min( pGrid );                         % [W] min. load on grid (infeed) 
    % self-consumption and self-dependency
    eSelfConsum = eGen - eFeedIn;                       % [Ws] self-consumed energy (generated - sold energy)     
    eSelfDepend = eConsum - ePurchase;                  % [Ws] self-supplied load energy (load - purchased energy) 
    rSelfConsum = eSelfConsum / eGen;                   % [pu] self-consumption rate 
    rSelfDepend = eSelfDepend / eConsum;                % [pu] self-dependency rate 
    
    %% calculate annual metrics for scenario with BESS
    % annual energy retrieved from and fed into the grid 
    annPPurchase    =   max(annPGrid, 0 );
    annPFeedIn      = - min(annPGrid, 0 );
    annEPurchase    = sum( annPPurchase )   .* tSample;
    annEFeedIn      = sum( annPFeedIn )     .* tSample;
    annECurtail     = sum( annPCurtail )    .* tSample;
    % annual peak power of grid
    annMaxPGrid     = max( annPGrid );
    annMinPGrid     = min( annPGrid );
    % self-consumption and self-dependency
    annESelfConsum  = annEGen - annEFeedIn;
    annESelfDepend  = annEConsum - annEPurchase;
    annRSelfConsum  = annESelfConsum ./ annEGen;
    annRSelfDepend  = annESelfDepend ./ annEConsum;
    
    %% calculate reference values for scenario without BESS
    netLoad         = load - generation;                % [W] net load
    pGridNoBS       = max( netLoad, feedInLimit );      % [W] power2Grid witohut BESS
    % no ES: power retrieved from and fed into the grid
    pPurchaseNoBS   =   max( pGridNoBS, 0 );            % [W] power drawn from grid
    pFeedInNoBS     = - min( pGridNoBS, 0 );            % [W] power feed-in 
    pCurtailNoBS    = pGridNoBS - netLoad;              % [W] curtailed power
    % energy to grid
    ePurchaseNoBS   = sum( pPurchaseNoBS )  * tSample;  % [Ws] energy bought from the grid 
    eFeedInNoBS     = sum( pFeedInNoBS )    * tSample;  % [Ws] energy fed into the grid 
    eCurtailNoBS    = sum( pCurtailNoBS )   * tSample;  % [Ws] energy lost to curtailment 
    % no ES: peak power of grid
    maxPGridNoBS    = max( pGridNoBS );                 % [W] max. load on grid 
    minPGridNoBS    = min( pGridNoBS );                 % [W] min. load on grid (infeed)
    % no ES: self-consumption and self-dependency energy
    eSelfConsumNoBS = eGen - eFeedInNoBS;               % [Ws] self-consumed energy (generated - sold energy)     
    eSelfDependNoBS = eConsum - ePurchaseNoBS;          % [Ws] self-supplied load energy (load - purchased energy)
    % FRR SSR
    rSelfConsumNoBS = eSelfConsumNoBS / eGen;           % [pu] self-consumption rate 
    rSelfDependNoBS = eSelfDependNoBS / eConsum;        % [pu] self-dependency rate 

    %% calculate annual values for scenario without BESS
    annNetLoad          = reshape(netLoad(:), [], nYears);
    annPGridNoBS        = max( annNetLoad, feedInLimit );
    % power to grid
    annPPurchaseNoBS    =   max( annPGridNoBS, 0 );
    annPFeedInNoBS      = - min( annPGridNoBS, 0);
    annPCurtailNoBS     = annPGridNoBS - annNetLoad;
    % energy to grid
    annEPurchaseNoBS    = sum( annPPurchaseNoBS )   .* tSample;
    annEFeedInNoBS      = sum( annPFeedInNoBS )     .* tSample;
    annECurtailNoBS     = sum( annPCurtailNoBS )    .* tSample;
    % peak power of grid
    annMaxPGridNoBS     = max( annPGridNoBS );
    annMinPGridNoBS     = min( annPGridNoBS );
    % self consumption and dependency energy
    annESelfConsumNoBS  = annEGen - annEFeedInNoBS;
    annESelfDependNoBS  = annEConsum - annEPurchaseNoBS;
    % FRR SSR
    annRSelfConsumNoBS  = annESelfConsumNoBS ./ annEGen;
    annRSelfDependNoBS  = annESelfDependNoBS ./ annEConsum;
    
    
    %% Write local vars into output struct
    % household load and pv produced energy
    result.solarHome___             = [];
    result.loadEnergy               = eConsum;
    result.generationEnergy         = eGen;
    
    % grid energy with BESS
    result.residentialBESS___       = [];
    result.purchasedEnergy          = ePurchase;
    result.feedInEnergy             = eFeedIn;
    result.curtailedEnergy          = eCurtailed;
    % grid power with BESS
    result.maxGridLoad              = maxPGrid;
    result.minGridLoad              = minpGrid;
    % self consumption and dependency with BESS
    result.selfConsumRate           = rSelfConsum;
    result.selfDependRate           = rSelfDepend;
    
    % grid energy wo BESS
    result.residentialNoBESS___     = [];
    result.noBESSPurchasedEnergy    = ePurchaseNoBS;
    result.noBESSFeedInEnergy       = eFeedInNoBS;
    result.noBESSCurtailedEnergy    = eCurtailNoBS;
    % grid power wo BESS
    result.noBESSMaxGridLoad        = maxPGridNoBS;
    result.noBESSMinGridLoad        = minPGridNoBS;
    % self consumption and dependency wo BESS
    result.noBESSSelfConsumRate     = rSelfConsumNoBS;
    result.noBESSSelfDependRate     = rSelfDependNoBS;
    
    
    %% Write annual values into struct
    annual.solarHome___             = [];
    annual.loadEnergy               = annEConsum;
    annual.generationEnergy         = annEGen;
    
    % grid energy with BESS
    annual.residentialBESS___       = [];
    annual.purchasedEnergy          = annEPurchase;
    annual.feedInEnergy             = annEFeedIn;
    annual.curtailedEnergy          = annECurtail;
    % grid power with BESS
    annual.maxGridLoad              = annMaxPGrid;
    annual.minGridLoad              = annMinPGrid;
    % self consumption and dependency with BESS
    annual.selfConsumRate           = annRSelfConsum;
    annual.selfDependRate           = annRSelfDepend;
    
    % grid energy wo BESS
    annual.residentialNoBESS___     = [];
    annual.noBESSPurchasedEnergy    = annEPurchaseNoBS;
    annual.noBESSFeedInEnergy       = annEFeedInNoBS;
    annual.noBESSCurtailedEnergy    = annECurtailNoBS;
    % grid power wo BESS
    annual.noBESSMaxGridLoad        = annMaxPGridNoBS;
    annual.noBESSMinGridLoad        = annMinPGridNoBS;
    % self consumption and dependency wo BESS
    annual.noBESSSelfConsumRate     = annRSelfConsumNoBS;
    annual.noBESSSelfDependRate     = annRSelfDependNoBS;
    
    ees.resultsTechnical        = result;
    ees.resultsTechnicalAnnual  = annual;
    
end

