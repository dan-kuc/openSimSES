%% OSPs
%   Simulate operation of PS storage
%
% Input ==
% ees   [-] storage object for OS
%
%
% Output ==
% ees   [-] storage object for OS
%
%
% Strategy is for the BESS  (load = load - maxPower).
% Excess power is stored in BESS and excess demand is supplied by BESS. 
% No forecast or consideration of system limits.
% To be called in runStorage method of residential class.
%
%   2019-05-12 Stefan Englberger
%   Update: 2019-07-08 Daniel Kucevic
%%

function [ ees ] = OSPeakShave( ees )
%% object data --> local vars
tSample         = ees.inputSim.tSample;        
simEnd          = ees.inputSim.simEnd;
simStart        = ees.inputSim.simStart;
%% Pre-calculations for simulation 
simTime         = (simStart:tSample:simEnd);
simTime         = simTime(2:end);
simPeriod       = (simEnd - simStart)/tSample;

pLoad           = ees.inputPSProfiles.load;
pPeakMax        = ees.inputTech.pPeakShaveThresh;
%% operation strategy & pre-calculations for simulation 
numOfSteps      = (simEnd - simStart) / tSample;                        % calculate # of iterations
netLoad         = pLoad - pPeakMax;                                     % compute net load
pRef            = - netLoad;                                            % reference is to offset net load

% loop to iterate through each timestep
for stepi = 1:numOfSteps                                             % run step
    ees.step( pRef(stepi), simTime(stepi) );                        
end % end dayi

end % end function

