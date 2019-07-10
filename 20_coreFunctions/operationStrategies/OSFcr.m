%% OSFcr
%   Simulate operation of FCR storage with different applications
%
%   2019-07-08 Daniel Kucevic        
%%
function [ ees ] = OSFcr( ees )

% powerStorageNow > 0 means discharge power to the grid
% powerStorageNow < 0 means charge power from the grid to the storage

%% Assigning of input parameters
inputSim    = ees.inputSim;
tSample     = inputSim.tSample;        
simEnd      = inputSim.simEnd;
simStart    = inputSim.simStart;

inputFcr    = ees.inputFcr;

%% Pre-calculations for simulation 
simTime         = (simStart:tSample:simEnd);
simTime         = simTime(2:end);
simPeriod       = (simEnd - simStart)/tSample;

% Initialize EES object
ees.step( 0, 0);

%% Simulation of FCR operation
for step = 1:simPeriod
    
    % Initialize vector for power values of different applications
    % 1: FCR | 2: IDM | 3: Residential | 4: External Load
    pStorageNow_Vec = zeros(4,1);

    % FCR: Calculate FCR load according to frequency deviation: powerStorageNow_Vec(1) 
    if inputFcr.flagFcrSupply
        getFcrLoad(ees);
    end
    pStorageNow_Vec(1) = ees.fcrData.fcrLoadNow;

    % IDM: Calculate IDM load every 15 minutes (idmTransactionFrequency) in order 
    % to keep system in desired SOC-range : powerStorageNow_Vec(2) 
    if inputFcr.flagIdmTransactions
        if(mod(step * tSample, inputFcr.idmTransactionTimeInterval) == 0)   
            getIdmLoad(ees);  
        end
    end
    pStorageNow_Vec(2) = ees.fcrData.idmLoadNow;


    %% Sum up power of different operation loads (Positive = Charge, Negative = Discharge)
    pStorageNow = sum(pStorageNow_Vec);

    % Store as soon as generation is present and use immediately
    ees.step( -pStorageNow, simTime(step) );

    setPowerDifference(ees, pStorageNow); 
    % Detection if reference power could not be met by system
    if step < simPeriod
        if(abs(ees.fcrData.fcrPowerDifference(step+1)) / pStorageNow > 0.01)
            warning(['Reference power could not be met by system. Step: ' num2str(step+1)])
        end
    end
    if mod(step,24*60*60) == 0
        disp(['Day: ' num2str(step/(24*60*60))]); 
    end
end
end
