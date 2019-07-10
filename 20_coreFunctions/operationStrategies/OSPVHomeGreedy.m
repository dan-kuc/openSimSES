%% OSGreedy
% OSGreedy function handle for operation strategy 'greedy' in application
% to increase self-consumption of system (e.g. residential home storage).
% Basically load shifting as task.
%
%
% Input ==
% EES   [-] storage object for OS
%
%
% Output ==
% EES   [-] storage object for OS
%
%
% Strategy is for the BESS to offset the residual load = load - generation.
% Excess power is stored in BESS and excess demand is supplied by BESS. 
% No forecast or consideration of system limits.
% To be called in runStorage method of residential class.
%
%   Update: 2019-07-08 Daniel Kucevic
%%

function [ ees ] = OSPVHomeGreedy( ees, varargin )
%% object data --> local vars
tSample     = ees.inputSim.tSample;        
simEnd      = ees.inputSim.simEnd;
simStart    = ees.inputSim.simStart;
load        = ees.inputProfiles.load;
genPV       = ees.inputProfiles.genPV;

%% pre-calculations for simulation 
kPerDay     = 24 * 3600 / tSample; 
dayStart    = max(simStart/(3600*24),1);
dayEnd      = simEnd/(3600*24);
simTime     = (simStart:tSample:simEnd);
simTime     = simTime(1:end);

%% operation strategy ===
netLoad = load - genPV;         % compute net load
pRef    = - netLoad;            % reference is to offset net load

% loops to iterate through each timestep 
for dayi = dayStart:dayEnd                                                  % loop for each day
    steps = ( ( dayi-1 ) * kPerDay + 1 ) : ( ( dayi ) * kPerDay );  % obtain steps of the day
    
    for step = steps 
        % loop for each timestep
        ees.step( pRef(step), simTime(step) );                                   % run step
    end % end step
end % end dayi

end % end function

