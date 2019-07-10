%% evalTechnicalPeakShaving
% Function computes technical results for a PS storage with and without BESS.
%
%   2018-12-05 Stefan Englberger
%   Update 2019-07-05 Daniel Kucevic
%
%%

function [ ees, result ] = evalTechnicalPeakShave( ees )
    % evaluation of technical storage data (application independent)
    result  = evalTechnical( ees );
    
    % ees vars --> local vars
    tSample = ees.inputSim.tSample;
    pLoad   = ees.inputPSProfiles.load;
    pPSGrid   = ees.pPSGrid;
    pThresh = ees.inputTech.pPeakShaveThresh;
    
    %% calculate metrics for scenario with BESS
    % energy retrieved from and fed into the grid     
    pPurchase   = max(pPSGrid, 0);                % [W] power drawn from grid with BESS
    ePurchase   = sum(pPurchase) * tSample; 	% [Ws] energy bought from the grid with BESS
    pGridMax    = max(pPSGrid);                   % [W] max. load on grid with BESS 
    
    violations  = max(0, pPSGrid - pThresh);
    kViolations = find(violations);
    pViolations = violations(kViolations);

    %% calculate matrics for scenario without BESS
    noBessPPurchase = max(pLoad, 0);                	% [W] power drawn from grid 
    noBessEPurchase = sum(noBessPPurchase) * tSample;   % [Ws] energy bought from the grid 
    pLoadMax        = max(pLoad);                       % [W] max. load on grid 
    
    violationsNoBess = max(0, pLoad - pThresh);
    kViolationsNoBess = find(violationsNoBess);
    pViolationsNoBess = violations(kViolationsNoBess);
    
    %% compare scenarios
    pPeakReduction      = pLoadMax - pGridMax;
    ePurchaseIncrease   = ePurchase - noBessEPurchase;
    
    %% Write local vars into output struct
    result.peakShaving___           = [];
    result.pGridPeak                = pGridMax;
    result.limViolationSteps        = kViolations;
    result.limViolationPower        = pViolations;
    result.purchasedEnergy          = ePurchase;
    % grid energy with and wo BESS
    result.peakShavingNoBess___     = [];
    result.pLoadPeak                = pLoadMax;
    result.noBessLimViolationSteps  = kViolationsNoBess;
    result.noBessLimViolationPower  = pViolationsNoBess;
    result.noBessPurchasedEnergy    = noBessEPurchase;
    
    % compare scenarios
    result.peakShavingEffect___     = [];
    result.peakReduction            = pPeakReduction;
    result.energyPurchaseIncrease   = ePurchaseIncrease;
    
    ees.resultsPSTechnical = result;
        
end

