%% Calculate technics of overall energy storage system
%
% Calculates a struct (resultTech) of the object, holding technical
% evaluations of the operation, losses, energy turnarounds, independent 
% from application.
% 
% Input == 
% EES                           [-]     storage object after simulation
%
% Output ==
% resultTech                    [-]     output struct with technical result fields
%   inStoredenergy              [Ws]    energy charged by BESS
%   outStoredEnergy             [Ws]    energy discharged by BESS
%   lossStorEnergy              [Ws]    losses by energy storage system
%   avgEtaSystem                [pu]    overall system efficiency
%   consumStorageOp             [Ws]    energy for aux components
%   capacityChangeCalendric     [Ws]    capacity change caused by calendric aging
%   capacityChangeCyclic        [Ws]    capacity change caused by cyclical aging
%   capacityChangeTotal         [Ws]    total capacity change
%
% 2017-04-18 Nam Truong 
%   2019-05-12 Stefan Englberger
%   Update: 2019-07-08 Daniel Kucevic
%
%%

function [ result ] = evalTechnical( ees )
    % EES vars --> local vars
    
    tSample         = ees.inputSim.tSample;             % [s]   sample time
    tSim            = ees.inputSim.simEnd;              % [s]   simulation time
    pStorage        = ees.pStorage;                     % [W]   power output of BESS
    pBatt           = ees.pBatt;                        % [W]   power output of battery
    eBattNom        = ees.inputTech.eBattNom;           % [Ws]  nominal energy of battery % Todo This probably has to take the SOH into account. 
    pBessNom        = ees.inputTech.pInverterNom;       % [W]   nominal power of BESS
    
    % in and outward energy of energy storage system
    pBessIn         =   max(pStorage, 0);               % [W]   charging power of BESS
    pBessOut        = - min(pStorage, 0);               % [W]   discharging power of BESS
    eBessIn         = sum(pBessIn) * tSample;           % [Ws]  energy stored into the storage system
    eBessOut        = sum(pBessOut) * tSample;          % [Ws]  energy retrieved from the storage system

if(isempty(ees.cellStates)==1)

    % losses and efficiencies
    % take into account possible soc variations
    dSoc            = diff(ees.soc([1,end]));           % [pu]  soc difference between t= 1 and t=end
    dEres           = dSoc * eBattNom;                  % [Ws]  energy surplus in storage vs starting state (losses not included)
    eLossStor       = eBessIn - eBessOut - dEres;       % [Ws]  losses by energy storage system corrected with allocated energy
    etaBessAvg      = 1 - eLossStor / eBessIn;          % [pu]  roundtrip efficiency of storage system
    eBessStby       = sum(ees.pStorageOp)* tSample;     % [Ws]  energy used to operate storage system % Todo this can be brought in later. 
    
    if dSoc>0
    ees.inputTech.battMdlParams.qNom  
    % full equivalent cycles
    pBattIn         =   max(pBatt, 0);                  % [W]   charging power of battery
    pBattOut        = - min(pBatt, 0);                  % [W]   discharge power of battery
    eBattIn         = sum(pBattIn)*tSample;             % [Ws]  energy stored in battery
    eBattOut        = sum(pBattOut)*tSample;            % [Ws]  energy discharged from battery
    fecE            = (eBattIn + eBattOut)/(2*eBattNom);% [-]   energy full equivalent cycle
    
    % battery losses 
    eLossBatt       = eBattIn - eBattOut - dEres; 
    
    
    % write states
    result.efficiency___    = [];
    result.eLossStor        = eLossStor;    % [Ws]  losses by energy storage system offset with allocated energy
    result.avgEtaSystem     = etaBessAvg;   % [pu]  roundtrip efficiency of storage system
    result.eConsumStorOp    = eBessStby;    % [Ws]  energy used to operate storage system 
    result.eLossBatt        = eLossBatt;    % [Ws]  battery that is lost due to battery loss mechanisms inside cell
    result.fullEqCycleE     = fecE;         % [-]   energy full equivalent cycle

end
end
    % utilization
    rUtilT      = 1 - sum(~pStorage)/length(pStorage);  % [pu]  time utilization rate
    rUtilE      = (eBessIn + eBessOut)/(pBessNom*tSim); % [pu]  energy utilization rate
    
    
    % Write local vars into output struct
    result.energy___        = [];
    result.eInStor          = eBessIn;      % [Ws]  energy stored into the storage system
    result.eOutStor         = eBessOut;     % [Ws]  energy retrieved from the storage system 
    
    result.utilization___   = [];
    result.rTimeUtil        = rUtilT;       % [pu]  time utilization rate
    result.rEnergyUtil      = rUtilE;       % [pu]  energy utilization rate
    
    %% aging
    % only evaluate aging, if aging has been calculated
    if strcmp(ees.inputTech.typeAgingMdl,'noaging')
        result.aging___         = 'noaging';
    else
        % calculate resulting aging values
        dCapCal         = sum(ees.capacityChangeCalendric);         % capacity change caused by calendric aging
        dCapCyc         = sum(ees.capacityChangeCyclic);            % capacity change caused by cyclical aging
        dCapTot         = sum(ees.capacityChangeTotal);             % total capacity change

        dResCal         = sum(ees.resistanceChangeCalendric);         % capacity change caused by calendric aging
        dResCyc         = sum(ees.resistanceChangeCyclic);            % capacity change caused by cyclical aging
        dResTot         = sum(ees.resistanceChangeTotal);             % total capacity change

        % Write local vars into output struct
        result.aging___         = [];
        result.dCapCal          = dCapCal;
        result.dCapCyc          = dCapCyc;
        result.dCapTot          = dCapTot;
        result.dResCal          = dResCal;
        result.dResCyc          = dResCyc;
        result.dResTot          = dResTot;

        result.sohCapNow        = ees.sohCapNow;
        result.sohResNow        = ees.sohResNow;
        result.temperature      = mean(ees.temperature);
        result.storageReplace   = ees.storageReplacement;

        result.dCapCalRelNow    = ees.totalRelCapacityChangeCalendricNow;
        result.dCapCycRelNow    = ees.totalRelCapacityChangeCyclicNow;
        result.dCapTotRelNow    = ees.totalRelCapacityChangeNow;
        result.dResCalRelNow    = ees.totalRelResistanceChangeCalendricNow;
        result.dResCycRelNow    = ees.totalRelResistanceChangeCyclicNow;
        result.dResTotRelNow    = ees.totalRelResistanceChangeNow;
    end
    
end

