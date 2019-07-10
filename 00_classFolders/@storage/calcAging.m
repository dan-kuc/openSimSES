%% calcAging
% 
%   Sets battery's SOH values of capacity and resistance calculated by the 
%   aging model. Needs to be called after the characterizeStress method is 
%   called.
%
%   Input/Output: EES object
%
%   This functions sets battery's SOH values of capacity and resistance,
%   which are calculated by calling the aging models wihtin the function 
%   callMethodAgingModels. There are different selectable options in form of
%   functions handels for calling the aging models:
%       - callMethodAgingModels_SingleValues
%       - callMethodAgingModels_AverageValues
%   Calendric, cyclic and total aging values are logged seperatly in the EES 
%   object depending on the selected logging option. The aging stress values,
%   which were used for the aging models, are logged inside the EES object.
%   This functions needs to be called after the characterizeStress method is 
%   called, to have all necessary input for the aging models.
%
%   2017-08-04   Maik Naumann
%%
function ees = calcAging( ees )

%% Assign input parameters
kNow        = ees.kNow;
sohCapNow   = ees.sohCapNow;
sohResNow   = ees.sohResNow;
eBattNom    = ees.inputTech.eBattNom;
resBattNom  = 1;
            
%% Calculate aging according to selected calling method
[detectedStress, agingCal, agingCyc, agingTotal] = ees.inputTech.callFctAgingMdl(ees);  

%% Logging of detected stress
agingStress                             = ees.agingStress;
agingStress.cumAgingTime                = detectedStress.cumAgingTime;
agingStress.cumRelCapacityThroughput    = detectedStress.cumRelCapacityThroughput;

% If logging is activated, all detected stress is logged
if(ees.inputSim.flagLogAging)  
    % Update EES aging stress values
    idxLog                          = detectedStress.idxLogging;
    agingStress.lastCycle(idxLog)   = detectedStress.lastCycle;
    agingStress.minSOC(idxLog)      = detectedStress.minSOC;
    agingStress.maxSOC(idxLog)      = detectedStress.maxSOC;
    agingStress.avgCRate(idxLog)    = detectedStress.avgCRate;
    agingStress.avgSOC(idxLog)      = detectedStress.avgSOC;
end

ees.agingStress = agingStress;

%% Calculate remaining capacity with aging factors
sohCapNow = max(sohCapNow + agingTotal.relCapacityChange,   0);
sohResNow = max(sohResNow - agingTotal.relResistanceChange, 0);

%% Update EES values
% Aging values needed for aging models
totalRelCapacityChangeCalendricNow      = ees.totalRelCapacityChangeCalendricNow   + agingCal.relCapacityChange;
totalRelResistanceChangeCalendricNow    = ees.totalRelResistanceChangeCalendricNow + agingCal.relResistanceChange;
totalRelCapacityChangeCyclicNow         = ees.totalRelCapacityChangeCyclicNow      + agingCyc.relCapacityChange;
totalRelResistanceChangeCyclicNow       = ees.totalRelResistanceChangeCyclicNow    + agingCyc.relResistanceChange;
totalRelCapacityChangeNow               = ees.totalRelCapacityChangeNow            + agingTotal.relCapacityChange;
totalRelResistanceChangeNow             = ees.totalRelResistanceChangeNow          + agingTotal.relResistanceChange;

% Logging of current changes of capacity and resistance due to aging. 
if(ees.inputSim.flagLogAging)  
    ees.capacityChangeCalendric(kNow)   = agingCal.relCapacityChange      * eBattNom;
    ees.capacityChangeCyclic(kNow)      = agingCyc.relCapacityChange      * eBattNom;
    ees.capacityChangeTotal(kNow)       = agingTotal.relCapacityChange    * eBattNom;
    ees.resistanceChangeCalendric(kNow) = agingCal.relResistanceChange    * resBattNom;
    ees.resistanceChangeCyclic(kNow)    = agingCyc.relResistanceChange    * resBattNom;
    ees.resistanceChangeTotal(kNow)     = agingTotal.relResistanceChange  * resBattNom;
% If logging is deactivated, log only current total values
else
    ees.capacityChangeCalendric(1)      = totalRelCapacityChangeCalendricNow     * eBattNom;
    ees.capacityChangeCyclic(1)         = totalRelCapacityChangeCyclicNow        * eBattNom;
    ees.capacityChangeTotal(1)          = totalRelCapacityChangeNow              * eBattNom;
    ees.resistanceChangeCalendric(1)    = totalRelResistanceChangeCalendricNow   * eBattNom;
    ees.resistanceChangeCyclic(1)       = totalRelResistanceChangeCyclicNow      * eBattNom;
    ees.resistanceChangeTotal(1)        = totalRelResistanceChangeNow            * eBattNom;
end

ees.totalRelCapacityChangeCalendricNow      = totalRelCapacityChangeCalendricNow;
ees.totalRelResistanceChangeCalendricNow    = totalRelResistanceChangeCalendricNow;
ees.totalRelCapacityChangeCyclicNow         = totalRelCapacityChangeCyclicNow;
ees.totalRelResistanceChangeCyclicNow       = totalRelResistanceChangeCyclicNow;
ees.totalRelCapacityChangeNow               = totalRelCapacityChangeNow;
ees.totalRelResistanceChangeNow             = totalRelResistanceChangeNow;


ees.sohCapNow       = sohCapNow;
ees.sohResNow       = sohResNow;
ees.sohCap(kNow)    = sohCapNow;
ees.sohRes(kNow)    = sohResNow;

end