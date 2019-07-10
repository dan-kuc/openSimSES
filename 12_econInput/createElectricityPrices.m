%% createElectricityPrices
% Function that generates scenarios of energy prices, using the selected
% method. 
%
% inputStruct = createElectricityPrices(inputStruct)
%
% Input == (parameters)
% structEconomics   [struct]    struct with economic parameters
%
% Output ==
% structEconomics   [struct]    struct with economic parameters
%
% Function to call just before object instantiation. Main simulation script
% for residential calls 'createEconParamPVHomeStorage', where this function
% is invoked.
% Electricity price is either extrapolated from historic data (2004 - 2017)
% with assumption that the price will stay constant or increases with fixed
% percentage.
%
% 2017-11-21 Maik Naumann / Nam Truong
% 
%%

function [ structEconomics ] = createElectricityPrices( structEconomics )

scenarioElectricityPrices   = structEconomics.pvHome.scenarioElectricityPrices;
inflationRate               = structEconomics.general.inflationRate;
depreciationPeriod          = structEconomics.general.depreciationPeriod;
yearNow                     = structEconomics.general.yearStart;
yearEnd                     = yearNow + depreciationPeriod - 1;

% Historic electricity prices: 2004-2017 [cEUR/kWh]
% BDEW, Bundesnetzagentur 3.500 kWh/year
historicElectricityPrices = [17.96; 
                            18.66; 
                            19.46; 
                            20.64; 
                            21.65; 
                            23.21; 
                            23.69; 
                            25.23; 
                            25.89; 
                            28.84; 
                            29.14;
                            28.70;
                            28.80;
                            29.23]; 

% Historical electricity prices: 2004-2017 [cEUR/kWh]
historicalInflationRate = ([1.6 1.6 1.5 2.3 2.6 0.3 1.1 2.1 2.0 1.5 0.9 0.3 0.5 1.8]'/100);
                        
historicElectricityPricesPeriod = [2004:2017];

%% If simulation period is not covered by historical values, interpolate with historical values
if(yearEnd > historicElectricityPricesPeriod(end))

    %% creating vectors for interpolation
    yearsExtrapolation      = 2004:1:yearEnd;                        
    tHistoricData           = length(historicElectricityPrices);
    tExtrapolation          = length(yearsExtrapolation) - tHistoricData;
    energyPricesConstant    = zeros(length(yearsExtrapolation),1);
    energyPricesLinear      = zeros(length(yearsExtrapolation),1);

    %% switch case for choosen electricity price scenario
    switch lower(scenarioElectricityPrices)
        % constant case: price only increases with inflation rate.
        case('constant')    
            energyPricesConstant(1:tHistoricData)   = historicElectricityPrices;

            for i = length(historicElectricityPrices)+1:length(energyPricesConstant)
                energyPricesConstant(i) = energyPricesConstant(i-1) * (1+inflationRate);
            end
            electricityPrice = energyPricesConstant(end-(depreciationPeriod-1):end)./ 100;

        % extrapolation with mean of historic growth rates
        case 'extrapolmeangrowth'
            rAnnGrowth              = historicElectricityPrices(2:end)./historicElectricityPrices(1:end-1);
            rGrowth                 = mean(rAnnGrowth);
            priceFactor             = rGrowth.^(1:(tExtrapolation));
            priceElectricityExtrap  = historicElectricityPrices(end) .* priceFactor;
            electricityPriceT       = [historicElectricityPrices; priceElectricityExtrap(:)];
            electricityPrice        = electricityPriceT(end-depreciationPeriod+1:end)/100;

        % extrapolation with avg. growth rate for first and last price value (sensitive if last price is outlier)
        case 'extrapolavggrowth'
            rTotalGrowth            = historicElectricityPrices(end) / historicElectricityPrices(1);
            rGrowth                 = nthroot(rTotalGrowth,tHistoricData);
            priceFactor             = rGrowth.^(1:(tExtrapolation));
            priceElectricityExtrap  = historicElectricityPrices(end) .* priceFactor;
            electricityPriceT       = [historicElectricityPrices; priceElectricityExtrap(:)];
            electricityPrice        = electricityPriceT(end-depreciationPeriod+1:end)/100;
       
        % extrapolation with mean of historic growth rates inflation-adjusted
       case 'extrapolmeangrowthinflationadjusted'
            rAnnGrowth              = historicElectricityPrices(2:end)./historicElectricityPrices(1:end-1);
            rGrowth                 = mean(rAnnGrowth - historicalInflationRate(1:end-1));
            priceFactor             = rGrowth.^(1:(tExtrapolation));
            priceElectricityExtrap  = historicElectricityPrices(end) .* priceFactor;
            electricityPriceT       = [historicElectricityPrices; priceElectricityExtrap(:)];
            electricityPrice        = electricityPriceT(end-depreciationPeriod+1:end)/100;

        % linear case: electricity price increases with fixed rate of extrapolation and inflation-adjusted
        % (extrapolated from historical values)
        case('linear')
            energyPricesFactor      = (historicElectricityPrices(end)/historicElectricityPrices(1) - 1) / length(historicElectricityPrices) + 1;  
            energyPricesFactorReal  = (energyPricesFactor / ( mean(historicalInflationRate) + 1) ) ; % real price gain factor after inflation [1/year]
            energyPricesLinear(1:tHistoricData)         = historicElectricityPrices;

            for i = length(historicElectricityPrices)+1:length(energyPricesLinear)
                energyPricesLinear(i) = energyPricesLinear(i-1) * energyPricesFactorReal;
                energyPricesConstant(i) = energyPricesConstant(i-1) * (1+inflationRate);
            end
            electricityPrice = energyPricesLinear(end-(depreciationPeriod-1):end)./ 100;

        otherwise
            warning('No case for electricity price scenario specified');

    end % end switch case

% Take historical values if simulation period is covered by period historical values
else
    index_Years = find(historicElectricityPricesPeriod == yearNow):find(yearEnd == historicElectricityPricesPeriod);
    electricityPrice = historicElectricityPrices(index_Years) / 100;
end

%% Display chosen scenario in command window
disp([mfilename('fullpath') ':'])
disp(['<strong> Electricity price scenario: ', scenarioElectricityPrices, '</strong>'])
% Write output variable
structEconomics.pvHome.electricityPrice = electricityPrice;

end