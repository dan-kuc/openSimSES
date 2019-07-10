%% calculateCashFlowResidential
% Function that calculates costs, revenue and cash flow per year for fcr
% supply
% Called by evalEconomics method.
% 
% INPUT: 
%   EES: storage object from simulation
%   economicParameters: struct containing economic parameters for the
%       simulation case residential
% OUTPUT:
%   econFcr: struct containing costs, revenue and cash flow
%       Each entry of dimension <yearsSimulated> x 1
% USAGE:
%   [residential, noEESresidential] = calculateCashFlowResidential(EES,
%   inputEconomics.residential)
% 
%   2017-01-04 Maik Naumann, Felix Kiefl
%%

function [ econFcr ] = calculateCashFlowFcr( ees, inputEconomics )
global gvarDAYS2SECONDS

fcrPrice = inputEconomics.fcr.fcrPrice(1:floor((ees.inputSim.simEnd - ees.inputSim.simStart)/(7*gvarDAYS2SECONDS)));

% Costs and revenues are calculated in the given time intervall of weeks of the FCR price profile

%% Determine costs of FCR supply
% No costs known or assumed
fcrCosts = zeros(length(fcrPrice),1);

%% Determine revenues of FCR supply
fcrRevenue = fcrPrice * ees.inputFcr.fcrMax / 1e6; % Divide by 1e6 for conversion of FCR price from €/MW to €/W
   
% Write output variables
econFcr.costs       = fcrCosts;
econFcr.revenue     = fcrRevenue;
econFcr.sampleTime  = gvarDAYS2SECONDS;

end