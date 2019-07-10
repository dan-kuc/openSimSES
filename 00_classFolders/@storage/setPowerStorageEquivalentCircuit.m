%% setPowerStorage
%   Method to set the power power of the storage system.
%
%   Method sets the method of the storage system within allowed limits.
%   Rated power of inverter is considered. Invoked functions also check the
%   SOC-limits and limit the powerStorage for the system to remain within
%   allowed operation limits.
%   Efficiency losses of the power electronics and the battery is included.
%   Proposed method to control the energy storage system.
%
%   2017-08-03 Truong
% Update 2019-07-05 Daniel Kucevic
%
%%


function [ ees ] = setPowerStorageEquivalentCircuit( ees, pStorageNow, varargin )
% object vars --> local vars (execution speed)
kNow                = ees.kNow;
tSample             = ees.inputSim.tSample;
etaInverter         = ees.etaInverter;      % AC2DC
etaInverterInv      = ees.etaInverterInv;   % DC2AC 
inputTech           = ees.inputTech;
pInverterNom        = inputTech.pInverterNom;
eBattNom            = inputTech.eBattNom; 
socNow              = ees.socNow;
temperatureAmbient  = inputTech.temperatureAmbient;
ecMdlParam          = inputTech.battMdlParams;
sohCapNow           = ees.sohCapNow;
sohResNow           = ees.sohResNow;
rBattSelfDisch      = inputTech.rSelfDischarge;
eLossSelfDis        = ees.eLossSelfDis;


% Update of EC-Model parameters with new SOC limits
socLimLow           = max(ecMdlParam.socMin, ees.socLimLow);
socLimHigh          = min(ecMdlParam.socMax, ees.socLimHigh);
ecMdlParam.socMin   = socLimLow;
ecMdlParam.socMax   = socLimHigh;

%% calculate inverter power
% add system standbyLoad to inverter power
pStbyLoad   = 0; % dummy of 0 watts --> model required
pACref      = pStorageNow - pStbyLoad;
[pDC, pAC]  = getPInverter(pACref, pInverterNom, etaInverter);

% update of battery temperature
if kNow == 1
    temperatureBattNow = temperatureAmbient;   % in case 
else
    temperatureBattNow = ees.temperature(kNow-1) ;
end

%% call of EC function: computes SOC via EC
[   pBattNow,       ...
    pBattLossNow,   ...
    ocvBattNow,     ...
    voltBattNow,    ...
    currentBattNow, ...
    socNew,         ...
    etaBattNow,     ...
    riNow,          ...
    eLossSelfDisNow ...
            ]       = battModel_EC_OCV_R( ...
                    pDC,                ...
                    tSample,            ...
                    socNow,             ...
                    sohCapNow,          ...
                    sohResNow,          ...
                    temperatureBattNow, ...
                    ecMdlParam,         ...
                    eBattNom,           ...
                    rBattSelfDisch      );

% check for limits of battery or power electronics
pBattNow    = min( pBattNow,  pInverterNom );
pBattNow    = max( pBattNow, -pInverterNom );
    
% pDC and pBatt deviate > 0.05 % --> recalculate pAc of inverter
if (abs(pDC-pBattNow)/pInverterNom > 5e-3) || pBattNow > pStorageNow
    pAC = getPInverter( pBattNow, pInverterNom, etaInverterInv );
end

% calculate the output of the storage system (inverter - stby)
pStorageNow     = pAC + pStbyLoad;

%% compute battery temperature
temperatureBatt     = inputTech.fctThermMdl( ...
                    pBattLossNow,       ...
                    ecMdlParam,         ...
                    temperatureBattNow, ...
                    temperatureAmbient, ...
                    tSample             );

%% update of object properties
if kNow <= ees.inputSim.simEnd
    ees.socNow          = socNew;
    ees.soc(kNow)       = socNew;       % update SOC trend
    ees.pStorageNow     = pStorageNow;
    ees.pStorage(kNow)  = pStorageNow;  % set powerStoragenow
    ees.pBattNow        = pBattNow;  
    ees.pBatt(kNow)     = pBattNow;     % set trend of power at battery terminal
    ees.temperature(kNow) = temperatureBatt;
    ees.pLossInv(kNow)  = abs(pBattNow - pStorageNow); 
    ees.eLossSelfDis    = eLossSelfDis + eLossSelfDisNow;
end

% Logging if flag for logging of battery EC output values is activated
if (isfield(ees.inputSim,'flagLogBattEc') && ees.inputSim.flagLogBattEc)
    ees.cellStates.powerLoss(kNow) = pBattLossNow;
    ees.cellStates.voltage(kNow)   = voltBattNow;
    ees.cellStates.current(kNow)   = currentBattNow;
    ees.cellStates.eta(kNow)       = etaBattNow;
    ees.cellStates.ocv(kNow)       = ocvBattNow;
    ees.cellStates.ri(kNow)        = riNow;
end

end % end of function

