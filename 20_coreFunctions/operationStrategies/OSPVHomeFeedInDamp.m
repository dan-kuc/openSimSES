%% 1.6.1 +++ Operation strategy 'feed-in damping'
%
% OSFeedInDamping function handle for operation strategy
% 'feed-in damping' in application to increase self-consumption of system
% (e.g. residential home storage).
%
% By storing the energy curtailed by the feed-in limit, curtailment losses
% will be avoided.
% By storing with a power depending on the spare charge of the storage and
% the predicted remaining time until sunset the storage will be nearly
% constantly charged over the complete sunshine duration.
% 
% Function implemented according to:
% Zeh, Alexander; Witzmann, Rolf (2014): Operational Strategies for Battery
% Storage Systems in Low-voltage Distribution Grids to Limit the Feed-in
% Power of Roof-mounted Solar Power Systems. In: Energy Procedia 46,
% S. 114�123. DOI: 10.1016/j.egypro.2014.01.164.
%
% Update 05.07.2019 Daniel Kucevic
%%

function [ ees ] = OSPVHomeFeedInDamp( ees, varargin )
%% Gather and prepare input data
global gvarDAYS2SECONDS

simStart    = ees.inputSim.simStart;
simEnd      = ees.inputSim.simEnd;
tSample     = ees.inputSim.tSample;
simTime     = (simStart:tSample:simEnd);
simTime 	= simTime(2:end);
kPerDay     = gvarDAYS2SECONDS / tSample;
dayStart    = max(simStart/gvarDAYS2SECONDS, 1);
dayEnd      = simEnd / gvarDAYS2SECONDS;
eta         = mean(ees.etaInverter((length(ees.etaInverter)+1)/2:end))*mean(ees.etaBatt((length(ees.etaBatt)+1)/2:end));

if isempty(ees.pStorageOp)
    pNet    = ees.inputProfiles.load - ees.inputProfiles.genPV; % residual load from consumption and generated power
    pNetFC  = ees.inputForecast.load - ees.inputForecast.genPV; % predicted residual load from consumption and generated power
else
    pNet    = ees.inputProfiles.load + ees.pStorageOp - ees.inputProfiles.genPV; % residual load from consumption and generated power
    pNetFC  = ees.inputForecast.load + ees.pStorageOp - ees.inputForecast.genPV; % predicted residual load from consumption and generated power
end

%% Loop for each day that is simulated
for dayi = dayStart:dayEnd	% iterate from day EES.simStart to day EES.simEnd
    
    stepEnd = (dayi - 1) * kPerDay;	% set stepEnd to 0 at the beginning of every day in the for-loop
    
    %% Determine at which simstep sunset occurs
    for k = (dayi * kPerDay):-1:((dayi - 1) * kPerDay + 1)   % run backwards through all steps of dayi to get timestep of sunset
        if pNetFC(k) < 0	% if sun is shining
            stepEnd = k;	% timestep where sun sets
            break
        end
    end
    
    %% Loop from beginning of the day until sunset
    if stepEnd ~= (dayi - 1) * kPerDay
        
        for k = (dayi - 1) * kPerDay + 1:stepEnd
            
            eBattNow = ees.sohCapNow * ees.inputTech.eBattNom;
            
            if pNet(k) < 0 % more generation than consumption. Battery is charged. Positive values for charging power
                
                    pRef = eBattNow * (1 - ees.socNow) / ((stepEnd + 1 - k) * tSample * eta);      % ...charge in the battery with the predicted daytime with radiation (-->s)
                    
                    if pRef > -pNet(k)% set storage to residualLoad if residualLoad is smaller than charging power...
                        ees.step(-pNet(k), simTime(k)); % or discharge if residualLoad is positive
                    else % otherwise charge with chargingpower
                        ees.step(pRef, simTime(k));
                    end
                
            else % more consumption than generation. Battery is discharged. Negative values for charging power.
                ees.step(-pNet(k), simTime(k));
            end
        end %end of loop until sunset
    end
    
    %% Loop from sunset to end of day
    for k = stepEnd + 1:dayi * kPerDay                             % discharge battery after sunset
        ees.step(-pNet(k), simTime(k));
    end
end % end loop for each day

end
%% Modification history
% Created
% 27 OCT 2015
% Nam Truong
% 
% Updated
% 28 AUG 2017 
% Markus Foerstl
% 
% Copied OSFeedInDamping, made some changes and renamed file
% unknown date
% Unknown


