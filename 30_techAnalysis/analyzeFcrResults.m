%% FCR check
% Check power differences and extract evaluation numbers
%   Update: 2019-07-08 Daniel Kucevic
%%
for idx_ees = 1:numel(ees)
    fcrValidation(idx_ees).power2EnergyRatio    = ees{idx_ees}.inputFcr.power2EnergyRatio;
    fcrValidation(idx_ees).numPowerDifferences  = numel(find(ees{idx_ees}.fcrData.fcrPowerDifference ~= 0));
    fcrValidation(idx_ees).relEnergyDifferences = sum(abs(ees{idx_ees}.fcrData.fcrPowerDifference(ees{idx_ees}.fcrData.fcrPowerDifference ~= 0))) / ees{idx_ees}.inputTech.batteryNominalEnergy;
    fcrValidation(idx_ees).socLimitLow          = numel(find(ees{idx_ees}.SOC == 0));
    fcrValidation(idx_ees).socLimitHigh         = numel(find(ees{idx_ees}.SOC == 1));
    fcrValidation(idx_ees).numIdcSell           = numel(find(ees{idx_ees}.fcrData.idcOut > 0));
    fcrValidation(idx_ees).numIdcBuy            = numel(find(ees{idx_ees}.fcrData.idcOut < 0));
    
    resultsTechnicalFcr                         = ees{idx_ees}.resultsTechnicalFcr;
    
    resultsTechnicalFcr.averageSOC              = mean(ees{idx_ees}.SOC);
    resultsTechnicalFcr.averageChargeCrate      = mean(ees{idx_ees}.powerStorage(ees{idx_ees}.powerStorage>0))/ees{idx_ees}.inputTech.batteryNominalEnergy*3600;
    resultsTechnicalFcr.averageDischargeCrate   = mean(ees{idx_ees}.powerStorage(ees{idx_ees}.powerStorage<0))/ees{idx_ees}.inputTech.batteryNominalEnergy*3600;
    resultsTechnicalFcr.maxChargeCrate          = max(ees{idx_ees}.powerStorage(ees{idx_ees}.powerStorage>0))/ees{idx_ees}.inputTech.batteryNominalEnergy*3600;
    resultsTechnicalFcr.maxDischargeCrate       = min(ees{idx_ees}.powerStorage(ees{idx_ees}.powerStorage<0))/ees{idx_ees}.inputTech.batteryNominalEnergy*3600;
    
    
    if(ees{1}.inputSim.logAgingResults)
        [~, DOC] = calcCRateDOC(ees{idx_ees});
        resultsTechnicalFcr.averageDOC              = mean(abs(DOC(DOC~=0)));
        resultsTechnicalFcr.averageChargeDOC        = mean(DOC(DOC>0));
        resultsTechnicalFcr.averageDischargeDOC     = -mean(DOC(DOC<0));
    end
    
    resultsTechnicalFcr.FEC                     = sum(abs(ees{idx_ees}.powerBatt)*ees{idx_ees}.inputSim.sampleTime)/ees{idx_ees}.inputTech.batteryNominalEnergy/2;
    resultsTechnicalFcr.FEC                     = ees{idx_ees}.agingStress.cumRelCapacityThroughput/2; 
    
    FCR.resultsTechnicalFcr(idx_ees)            = ees{idx_ees}.resultsTechnicalFcr;
    FCR.resultsEconomicsFcr(idx_ees)            = ees{idx_ees}.resultsEconomicsFcr;
    FCR.inputTech(idx_ees)                      = ees{idx_ees}.inputTech;
    FCR.inputFcr(idx_ees)                       = ees{idx_ees}.inputFcr;
end
%%
% Saving workspace variables.
% Save ees object.
save(['07_Results\FCR_1a_PE0_4_RES','.mat'], 'FCR','fcrValidation')