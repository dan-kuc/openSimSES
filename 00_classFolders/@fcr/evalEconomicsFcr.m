%% evalEconomics
%   FCR class method to evaluate economic values of FCR storage system
%   together with the IDC transactions and the residential power exchange
%
%   2017-01-05 Maik Naumann, Felix Kiefl
%%
function [ ees ] = evalEconomicsFcr( ees, inputEconomics, timeFactor )

% Assign economic input to object
if nargin > 1
    setInputEconomics(ees, inputEconomics);
end

% Calculate storage investment (CAPEX) and pure technical operation costs (OPEX)
storageCost     = calculateStorageCosts( ees );

% Calculate cashflows of all applications when available
if(ees.inputFcr.flagFcrSupply)
    cashflow.fcr    = calculateCashFlowFcr( ees, inputEconomics );
end
if(ees.inputFcr.flagIdcTransactions)
    cashflow.idc    = calculateCashFlowIdc( ees, inputEconomics );
end
if(ees.inputFcr.flagResidential)
    [cashflow.resEes, cashflow.resNoEes] = calculateCashFlowRes( ees );
end

% Calculate key figures (PI, LCOE, NPV)
resultFcr          = analyzeFcrEconomics( ees, storageCost, timeFactor, cashflow ); 

% Assign economic results to object.
ees.resultsEconomicsFcr = resultFcr;

end