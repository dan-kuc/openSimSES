%% analyzeEconomics
% This function calculates economic characteristics (NPV, ROI...) based on
% costs & revenue It is called after the simulation has finished and is
% able to be called independently, as it only uses cash flow and economic
% parameters (e.g. interestRate, depreciationPeriod etc.) Together with the
% calculateCashFlow-functions this function replaces the old evalEconomics
% function.
% Called by evalEconomics method.
%   
%   INPUT
%       economicsSimulation: struct containing costs, revenue and cash flow of the
%           simulation data (maybe change name to something more generic?)
%       costsStorage: struct containing costs of the storage
%       economicParameters: struct containing parameters like inflation,
%           interest rate...
%       
%       optional
%       referenceEconomics: struct containing costs, revenue and cash flow of a
%           reference, e.g. in residential case the data for a simulation
%           without storage system
% 
%   OUTPUT
%       result: struct with the results of the analysis (NPV, IRR, ROI...)
% 
% 2017-10-10 Nam Truong / M.Förstl
%%

function [ result ] = analyzeEconomics( ees, storageCost, varargin )


global gvarKWH2WS

%% Prepare input data
nUse = numel(varargin); % # of applications (multi-use)
for k = 1:nUse
    inputCashflow(k) = varargin{k}; %#ok<AGROW>
end

depreciationPeriod  = ees.inputEconomics.general.depreciationPeriod;
interestRate        = ees.inputEconomics.general.interestRate;
inflationRate       = ees.inputEconomics.general.inflationRate;

%% Calculate Interest Rates
realInterestRate    = (1 + interestRate) ./ (1 + inflationRate) - 1;    % real interest rate including inflation
realInterestFactor  = 1 + realInterestRate;                             % factor
discountFactor      = realInterestFactor .^ ((1:depreciationPeriod)');  % discounting factors for each year


%% Gross value
% Calculation without consideration of time dependency.

% Numbers with storage
investCost          = storageCost.invest(1);
investSubsidy       = investCost * ees.inputEconomics.pvHome.investSubsidy;
cashflow            = inputCashflow.ees.revenue - inputCashflow.ees.costs;
systemCost          = storageCost.replacement + storageCost.maintenance;

% Numbers without storage
investCostNoEes     = 0;
cashflowNoEes       = inputCashflow.noEes.revenue - inputCashflow.noEes.costs;
% fill empty fields with 0
for k = 1:nUse
    if isempty( cashflowNoEes(k) )
        cashflowNoEes(k) = 0 * cashflow(k);
    end
end
systemCostNoEes     = 0 * systemCost;

% Savings by storage
investSavings       = investCostNoEes - investCost + investSubsidy;
cashflowSavings     = cashflow - cashflowNoEes;
systemCostSavings   = systemCostNoEes - systemCost;


%% Net present values
% Consideration time value of money.

% NPV for storage
NPVInvest               = investCost;
NPVInvestSubsidy        = investSubsidy;
NPVCashflow             = cashflow(:).'     * discountFactor;
NPVSystemCost           = systemCost(:).'   * discountFactor;
NPVSum                  = NPVInvest - NPVInvestSubsidy + NPVCashflow + NPVSystemCost;

% NPV without storage
NPVInvestNoEes          = investCostNoEes;
NPVCashflowNoEes        = cashflowNoEes(:).'    * discountFactor;
NPVSystemCostNoEes      = systemCostNoEes(:).'  * discountFactor;
NPVSumNoEes             = NPVInvestNoEes + NPVCashflowNoEes + NPVSystemCostNoEes;

% Savings
NPVInvestSavings        = investSavings;
NPVCashflowSavings      = cashflowSavings(:).'      * discountFactor;
NPVSystemCostSavings    = systemCostSavings(:).'    * discountFactor;
NPVSumSavings           = NPVInvestSavings + NPVCashflowSavings + NPVSystemCostSavings;

%% Calculate Profitability Index (PI) (see: DOI 10.1038/NENERGY.2016.79)
% PI is defined as the Net Present Value divided by the investment costs
% Essentially, profitabilityIndex is the same as the ROI (according to our
% definition)
profitIdx   = NPVSumSavings / NPVInvest;

%% Calculate Internal Rate of Return (iROR)
if(license('test','Financial_toolbox') && exist('irr'))
    % IRR can only be calculated when MATLAB Financial Toolbox is installaed/licensed
    [iROR, ~]   = irr([investSavings, ( cashflowSavings(:) + systemCostSavings(:) ).']);
else
    warning('MATLAB Financial Toolbox is not installaed/licensed: Calculation of IRR not possible');
    iROR        = [];
end

%% Levelized cost of energy stored (LCOES)
% EUR per kWh discharged
lcoes       = ( NPVInvest - NPVInvestSubsidy ) / ( ees.resultsTech.eOutStor / gvarKWH2WS );


%% Store results in struct
result                      = struct; 

% simulation data
result.simulation_____      = '_____';
result.NPVInvest            = NPVInvest; 
result.NPVInvestSubsidy     = NPVInvestSubsidy; 
result.NPVCashflow          = NPVCashflow; 
result.NPVSystemCost        = NPVSystemCost;
result.NPVSum               = NPVSum;

% reference data without storage
result.reference_____       = '_____'; 
result.NPVInvestNoEes       = NPVInvestNoEes;
result.NPVCashflowNoEes     = NPVCashflowNoEes; 
result.NPVSystemCostNoEes   = NPVSystemCostNoEes; 
result.NPVSumNoEes          = NPVSumNoEes;

% Comparison
result.savings_____         = '_____'; 
result.NPVInvestSavings     = NPVInvestSavings; 
result.NPVCashflowSavings   = NPVCashflowSavings;
result.NPVSystemCostSavings = NPVSystemCostSavings; 
result.NPVSumSavings        = NPVSumSavings; 

% key performance indicators
result.metrics_____         = '_____';
result.LCOES                = lcoes;
result.IRR                  = iROR;
result.profitIdx            = profitIdx; 


end

