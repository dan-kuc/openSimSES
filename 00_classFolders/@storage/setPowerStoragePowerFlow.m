%% setPowerStorage 
% Method sets the method of the storage system within allowed limits.
% Rated power of inverter is considered. Invoked functions also check the
% SOC-limits and limit the powerStorage for the system to remain within 
% allowed operation limits.
% Efficiency losses of the power electronics and the battery is included.
% Proposed method to control the energy storage system.
%   
% 2017-08-03 Truong
%   
%%


function [ ees ] = setPowerStoragePowerFlow( ees, pStorageNow, varargin )
% multiple used properties written in variables (execution speed)
k               = ees.kNow;
tSample         = ees.inputSim.tSample;
inputTech       = ees.inputTech;
etaAccur        = inputTech.etaAccuracy;
etaInverter     = ees.etaInverter;      % AC2DC
etaInverterInv  = ees.etaInverterInv;   % DC2AC 
pInverterNom    = inputTech.pInverterNom;
pBattNom        = inputTech.pBattNom;
eBattNom        = inputTech.eBattNom;
socNow          = ees.socNow;
socLimLow       = ees.socLimLow;
socLimHigh      = ees.socLimHigh;
sohCapNow       = ees.sohCapNow;
eLossSelfDis    = ees.eLossSelfDis; 
% SOHresNow       = ees.SOHresistanceNow;
rBattSelfDis  = inputTech.rSelfDischarge;

%relevant for incremental inverter operation (Anupam Parlikar on
%14.02.2019)
inverterNumber  = ees.inputTech.inverterNumber; %TODO added on 24.01.2019
inverterSwitch  = ees.inputTech.inverterSwitch;
%% calculate inverter power
% add system standbyLoad to inverter power
pStbyLoad   = 0; % dummy of 0 watts --> model required
pACref      = pStorageNow - pStbyLoad;
[pDC, pAC]  = getPInverter(pACref, pInverterNom, etaInverter, inverterNumber, inverterSwitch);

% check for limits of battery or power electronics
pBattNow    = min(pDC,       pBattNom);
pBattNow    = max(pBattNow, -pBattNom);
pBattNow    = min(pBattNow,  pInverterNom);
pBattNow    = max(pBattNow, -pInverterNom);

if pDC ~= pBattNow
    warning('pBattNow and pDC are different. Check calculation.')
end

% if power is adjusted to limit, recalculate pAc of inverter
if ((abs(pDC) - abs(pBattNow)) / pInverterNom > 0.01) || (pBattNow > pStorageNow)
    pAC = getPInverter(pBattNow, pInverterNom, etaInverterInv, inverterNumber, inverterSwitch);
end

%% calculate SOC
% calculates the resulting SOC depending on the power at battery terminals
etaIdx      = ceil(etaAccur * (pBattNow / pBattNom + 1) + 1);   % obtain normalized power and respective array idx for efficiency curve
etaBattNow  = ees.etaBatt(etaIdx);                              % get efficiency value for power value
pSOC        = etaBattNow * pBattNow;                            % calculate power in battery cell
dSOC        = pSOC /(sohCapNow * eBattNom) * tSample;           % calculate delta SOC
socNew      = dSOC + socNow;                                    % calculate new possible SOC, if no thresholds are violated

%% check for operational constraints
% no more charging if SOC == 1, no more discharging if SOC == 0
if ((dSOC <= 0) && (socNow == socLimLow))||((dSOC >= 0) && (socNow == socLimHigh))
    socNew      = socNow;   % SOC unchanged
    pAC         = 0;        % no powerStorage because SOC is at limit already
    pBattNow    = 0;        % calculate powerBatt accordingly
    
    % If chosen power would lead to exceeding SOC, powers need to be reduced.
    % Assumption: Full provision of requested power until SOC-limit is reached.
    % Power output is then reduced to 0, thus avg. power of time-step is used.
elseif ((socNew < socLimLow) || (socNew > socLimHigh))
    % Self discharge should decrease SOC, if SOClimLow > 0
    if(socLimLow > 0 && pBattNow == 0)
        socNew = dSOC + socNow;
    else
        socNew      = max(socNew, socLimLow);       % SOC within lower boundary
        socNew      = min(socNew, socLimHigh);      % SOC within upper boundary
        limFactor   = (socNew - socNow) / dSOC;     % ratio to reduce powers at current timestep
        % if limfactor = inf or nan, set to 0
        if (isnan(limFactor) || isinf(limFactor))
            limFactor = 0;
        end
        pAC   = limFactor * pAC;                    % reduce powerStorage to achieve SOC limit
        pBattNow    = limFactor * pBattNow;         % calculate powerBatt accordingly
    end
end

%% calculate self discharge

% Assumption: 
%   - Self discharge occurs always: Equally in idle periods

dSocSelfDischarge = - rBattSelfDis * tSample * 1/sohCapNow;
socNew  = max(socNew + dSocSelfDischarge, 0);
eLossSelfDis = eLossSelfDis + abs(dSocSelfDischarge * eBattNom);


% calculate the output of the storage system (inverter - stby)
pStorageNow = pAC + pStbyLoad;

% calculate temperature of battery for aging ambient temperature is assumed
% for now.
% Placeholder for thermal model
temperatureBatt = inputTech.temperatureAmbient;

%% update of object properties
ees.pLossInv(k)     = abs(pBattNow - pStorageNow);
ees.eLossSelfDis    = eLossSelfDis;     
ees.socNow          = socNew;
ees.soc(k)          = socNew;
ees.pStorageNow     = pStorageNow;
ees.pStorage(k)     = pStorageNow;
ees.pBattNow        = pBattNow;
ees.pBatt(k)        = pBattNow;
ees.temperature(k)  = temperatureBatt;

% if pBattNow ~= 0 % This code is not functional. It is error-prone in that
% it calculates losses when pSOC has not been honoured and pBattNow is
% drastically different from pSOC
%     ees.pLossBatt(k)= abs(pSOC - pBattNow);
% else
%     ees.pLossBatt(k)= 0;
% end

end % end of function
