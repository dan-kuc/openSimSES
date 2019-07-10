%% getIdmLoad
%   Sets the power for IDM transactions to control SOC
%   
%   2017-01-04 Maik Naumann, Felix Kiefl
%   2018-09-12 Update Daniel Kucevic
%%
function ees = getIdmLoad(ees)

% idmOut > 0 means discharge power to the grid
% idmOut < 0 means charge power from the grid to the storage

%% Assign input parameters
% Description of parameters in createFcrData
% simStepNow                  = ees.tNow - 1; % MF: Why -1?
simStepNow                  = ees.tNow + 1;
idmOffsetTime               = ees.inputFcr.idmOffsetTime;
idmMinimalTransactionVolume = ees.inputFcr.idmMinimalTransactionVolume;
idmTransactionTimeInterval  = ees.inputFcr.idmTransactionTimeInterval;
idmFirstGuessTime           = ees.inputFcr.idmFirstGuessTime;
idmTimeWait                 = ees.inputFcr.idmTimeWait;

indexIDM                    = ees.fcrData.indexIDM;
storRemainCapacitynow       = ees.inputTech.eBattNom * ees.sohCapNow;
eta                         = ees.inputFcr.eta;
idmIndexOffset              = ees.inputFcr.idmIndexOffset;

% Limit maximum power of IDM transaction due to FCR power requirements when
% applying IDM worst case scenario
powerMaxIn                  = -ees.inputFcr.fcrMax;
powerMaxOut                 =  ees.inputFcr.fcrMax;

%% Determine required power of IDM transactions (idmOut) in order control SOC
% Determine delta SOC of preceding IDM transactions
% Skipping first half an hour because of missing historic values
if(indexIDM > idmIndexOffset && (indexIDM + idmIndexOffset) <= length(ees.fcrData.idmOut))
    dSocIdm = sum(ees.fcrData.dSocIdm(indexIDM : indexIDM + idmIndexOffset));
else
    dSocIdm = 0;
end

% Determine time until maximal FCR requirements can be still fulfilled with current soc
 
if(ees.inputFcr.flagNewRegulations)
    % Subtract 30 minutes (idmOffsetTime) for soc criteria of regulations
    time_max_in    = -storRemainCapacitynow / (powerMaxIn * eta) * (1 - (ees.socNow + dSocIdm)) - idmTransactionTimeInterval;     
    time_max_out   = storRemainCapacitynow / (powerMaxOut / eta) * (ees.socNow + dSocIdm) - idmTransactionTimeInterval;    
else
    time_max_in    = -storRemainCapacitynow / (powerMaxIn * eta) * (1 - (ees.socNow + dSocIdm)) * idmTimeWait;
    time_max_out   = storRemainCapacitynow / (powerMaxOut / eta) * (ees.socNow + dSocIdm) * idmTimeWait;
end

%% Check if SOC requirements can be still fulfilled in worst case
% Assign default power for IDM transaction
idmOut = 0;


% Adjust SOC with optimized IDM transaction parameters  

if(time_max_in*idmTimeWait < ees.inputFcr.idmTimeSell/2)
    idmOut = abs(ees.inputFcr.socSet - ees.socNow + dSocIdm) * eta * storRemainCapacitynow / idmTransactionTimeInterval;                
elseif(time_max_out*idmTimeWait < ees.inputFcr.idmTimeBuy/2)
    idmOut = -abs(ees.inputFcr.socSet - ees.socNow + dSocIdm) / eta * storRemainCapacitynow / idmTransactionTimeInterval;
end
 

% Adjust IDM power to minimum IDM transaction volume
idmOut = ceil(abs(idmOut) / idmMinimalTransactionVolume) * idmMinimalTransactionVolume * sign(idmOut); 
% Adjust IDM power to maximum FCR power in charge and discharge direction
if powerMaxOut * ees.inputFcr.idmPowerLimitFactor < idmMinimalTransactionVolume || abs(powerMaxIn * ees.inputFcr.idmPowerLimitFactor) < idmMinimalTransactionVolume 
    warning('Power Limit for IDM-Market is below minimal Transaction Volume');
end
idmOut = min(idmOut, powerMaxOut * ees.inputFcr.idmPowerLimitFactor);
idmOut = max(idmOut, powerMaxIn * ees.inputFcr.idmPowerLimitFactor);

% Determine delta SOC of current IDM transactions
dSocIdmNow = -idmOut*idmTransactionTimeInterval / storRemainCapacitynow;

% Update idm output power and delta SOC for delay of 
ees.fcrData.idmOut(indexIDM + idmIndexOffset)   = idmOut;
ees.fcrData.dSocIdm(indexIDM + idmIndexOffset)  = dSocIdmNow; % dSocIdm only for transaction times, not whole time vector

% Set values of half an hour ago als current values for storage charge/discharge
if(indexIDM > idmIndexOffset)
    ees.fcrData.idmLoadNow = ees.fcrData.idmOut(indexIDM); 
end

% Logging
if(ees.inputFcr.flagLogFcrResults)
    ees.fcrData.idmLoad(simStepNow:simStepNow+idmTransactionTimeInterval) = ees.fcrData.idmLoadNow;
end

% Update indexIDM
ees.fcrData.indexIDM = indexIDM + 1;
end