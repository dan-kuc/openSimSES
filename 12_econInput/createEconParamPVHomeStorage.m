% storage costs, peripheric price etc. is generated in the specified case (scenarioStorageCosts)
[inputEcon.batteryInvestmentCostFixed, ...
 inputEcon.batteryInvestmentCostVariable, ...
 inputEcon.inverterInvestmentCostFixed, ...
 inputEcon.inverterInvestmentCostVariable, ...
 inputEcon.storagePeriphericCost, ...
 inputEcon.storageMaintenanceCost]   = createStorageCosts( ...
                                        'scenarioStorageCosts',     inputEcon.scenarioStorageCosts, ... 
                                        'KfWRateSubsidy',           inputEcon.KfWRateSubsidy);

% generate electricity price
[inputEcon.electricityPrices]        = createElectricityPrices( ...
                                        'scenarioElectricityPrices',inputEcon.scenarioElectricityPrices, ...
                                        'inflationRate',            inputEcon.inflationRate, ...
                                        'depreciationPeriod',       inputEcon.depreciationPeriod );    