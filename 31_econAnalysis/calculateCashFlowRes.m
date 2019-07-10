%% calculateCashFlowResidential
% Function that calculates costs, revenue and cash flow per year for
% residential case and only for residential case.
% Called by evalEconomics method.
% 
% INPUT: 
%   EES: storage object from simulation
%   economicParameters: struct containing economic parameters for the
%       simulation case residential
% OUTPUT:
%   econResidential and econNoEESresidential: 2 structs (simulation with and without EES) containing costs, revenue and cash flow
%       Each entry of dimension <yearsSimulated> x 1
% USAGE:
%   [residential, noEESresidential] = calculateCashFlowResidential(EES,
%   inputEconomics.residential)
% 
% STATUS: working as of Aug 22, 2017
% 
% Markus Förstl 

function [ resultEes, resultNoEes ] = calculateCashFlowRes( ees )
global gvarYEARS2SECONDS gvarKWH2WS

tSample             = ees.inputSim.tSample;
pGrid               = ees.pGrid;
electricityPrices   = ees.inputEconomics.pvHome.electricityPrice; 
feedInRemuneration  = ees.inputEconomics.pvHome.feedInRemuneration;  

%% Case with EES
% Get consumption and feedIn 
pFromGrid       = max( pGrid, 0);   % power drawn from grid [W]
p2Grid          = max(-pGrid, 0);  % power injected into grid [W]
% Calculate Energy
eConsumption   = pFromGrid * (tSample / gvarKWH2WS); % consumed energy [kWh]
eFeedIn        = p2Grid    * (tSample / gvarKWH2WS); % feed in energy [kWh]

% Reshape data to a matrix with <years simulated> columns
if ~mod(length(eConsumption), gvarYEARS2SECONDS / tSample)
    consumptionMatrix   = reshape(eConsumption,   gvarYEARS2SECONDS/tSample, []); 
    feedInMatrix        = reshape(eFeedIn,        gvarYEARS2SECONDS/tSample, []); 
else
    consumptionMatrix   = eConsumption; 
    feedInMatrix        = eFeedIn; 
end

% Column sums of the matrix are the cumulative energy consumption / feedIn
% values of each year
nSimYears           = length(consumptionMatrix(1,:));
annualConsumption   = sum(consumptionMatrix(:,1:nSimYears)).'; 
annualFeedIn        = sum(feedInMatrix(:,1:nSimYears)).';

% Calculate costs, revenue and cash flow
electricityCost = electricityPrices(1:nSimYears) .* annualConsumption;
feedInRevenue   = feedInRemuneration .* annualFeedIn;


%% Case without EES
% if curtailment limit for PV without storage is not equal to storage case,
% limits needs to be recalculated
curtailmentLimit    = -1 * ees.inputTech.rCurtPV * ees.inputTech.pPVnom;
residualLoad        = ees.inputProfiles.load - ees.inputProfiles.genPV; 
% curtail residual load above legal limit
residualLoad        = max(residualLoad, curtailmentLimit); 

% Get consumption and feedIn
noEESpowerFromGrid  = max( residualLoad, 0); 
noEESpower2Grid     = max(-residualLoad, 0); 

% Calculate Energy
noEESenergyConsumption  = noEESpowerFromGrid    * (tSample / gvarKWH2WS);
noEESenergyFeedIn       = noEESpower2Grid       * (tSample / gvarKWH2WS);

% Reshape data to a matrix with <years simulated> columns
if ~mod(length(noEESenergyConsumption), gvarYEARS2SECONDS / tSample)
    noEESconsumptionMatrix  = reshape(noEESenergyConsumption,   gvarYEARS2SECONDS/tSample, []); 
    noEESfeedInMatrix       = reshape(noEESenergyFeedIn,        gvarYEARS2SECONDS/tSample, []); 
else
    noEESconsumptionMatrix  = noEESenergyConsumption;
    noEESfeedInMatrix       = noEESenergyFeedIn;
end

% Column sums of the matrix are the cumulative energy consumption / feedIn
% values of each year
noEESannualConsumption  = sum(noEESconsumptionMatrix(:, 1:nSimYears))';
noEESannualFeedIn       = sum(noEESfeedInMatrix(:, 1:nSimYears))';

% Calculate costs, revenue and cash flow
noEESelectricityCost    = electricityPrices(1:nSimYears) .* noEESannualConsumption;
noEESfeedInRevenue      = feedInRemuneration .* noEESannualFeedIn;


% Write output variables
econResidential.costs           = electricityCost;
econResidential.revenue         = feedInRevenue;
econResidential.sampleTime      = tSample;

econNoEESresidential.costs      = noEESelectricityCost; 
econNoEESresidential.revenue    = noEESfeedInRevenue; 
econNoEESresidential.sampleTime = tSample;

resultEes     = econResidential;
resultNoEes   = econNoEESresidential;

end


