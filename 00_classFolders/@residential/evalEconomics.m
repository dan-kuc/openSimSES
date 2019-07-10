%% evalEconomics
% Residential class method to evaluate economic value of pv home storage
% system.
%
% 2017-10-10 Nam Truong
%%

function [ ees ] = evalEconomics( ees, varargin )
 if nargin > 1
     ees.inputEconomics = varargin{1};
 end

% Calculate economic figures according to input parameters.
storageCost = calculateStorageCosts( ees );
cashflow    = calculateCashFlowResidential( ees );
% Calculate key figures (PI, LCOE, NPV)
result      = analyzeEconomics( ees, storageCost, cashflow ); 
% Store results in object.
ees.resultsEconomics = result;
 
end

