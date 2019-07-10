%% calcPowerResidual: calculates resulting residual power of power input which is not covered by storage
%   Calculation of the resulting residual power. All other power flows are
%   calculated in setPowerStorage.m: powerStorage, powerGen, powerConsump, powerStorageOp.
%
%   function owner: MN, NT
%   creation date:  24.03.2015
%   last updated:   23.02.2017
%
%   status: unknown
%
%%

function [ EES ] = calcPowerResidual( EES, powerInput )

% Define multiple used properties written in variables (execution speed)
stepNow = EES.stepNow;

% Residual power based on power input, possible storage power and storage operation consumption
powerResidualNow = EES.powerStorageNow - powerInput + EES.powerStorageOpNow; 

powerResidualNow = max(EES.power2GridMax(1), powerResidualNow);

% Update of object properties
EES.powerResidualNow        = powerResidualNow;
EES.powerResidual(stepNow)  = powerResidualNow;   

end

