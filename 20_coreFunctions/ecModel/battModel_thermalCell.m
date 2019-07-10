%% fThermalCell
% 0-D Lumped Mass Thermal Cell Model
% Thermal Cell Model which is based on a lumped mass for the single battery
% cell, heat transfer at the surface and one avg. temperature for both.
%
% Input ==
% pLoss             [W]     Losses in battery
% mdlParam          [-]     struct with model parameters
% tIn               [K]     cell-temperature of last simulation step
% tAmbient          [K]     Ambient temperature of battery cell
% timestep          [s]     length of timestep
%
% Output ==
% tOut              [K]     Resulting battery cell temperature
%
% Losses in battery cell and resulting temperature of cell is calculated.
%
% 2017-08-07 Schimpe
% 2017-08-08 Truong: Description needs to be checked!
%

function [ tOut ] = battModel_thermalCell( pLoss, mdlParams, tIn, tAmbient, timestep )

% Calculate loss per cell from the whole battery loss
pLossCell = pLoss / mdlParams.nCells;

% Calculate new battery temperature
tDelta = (pLossCell + mdlParams.thermA * mdlParams.thermAlpha * ...
            (tAmbient-tIn)) * timestep / mdlParams.thermM / mdlParams.thermCp;

tOut = tIn + tDelta;

% Check for big temperature jumps in one timestep. Will create warning when
% using big timesteps
if tOut < tAmbient
    tOut = tAmbient;
    warning('battModel_thermalCell:sampleTime','Cell temperature below ambient temperature. Possible source: chosen sample time too large.')
    warning('off','battModel_thermalCell:sampleTime')
end

end

