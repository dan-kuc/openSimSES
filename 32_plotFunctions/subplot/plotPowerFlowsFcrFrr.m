function [ h ] = plotPowerFlowsFcrFrr( ees, axis, profileTime, stepVector)
%plotStoragePower plots the storage power flows. It is called by
%plotFcrFrrProfile()
%
% INPUTS 
%   EES: Storage object (obligatory)
%   axis: axis handle
%   profileTime
%   stepVector
% OUTPUTS: h
% STATUS: functioning.
% LAST UPDATED: 2018-10-09
% OWNER: Daniel Kucevic

%% Get default figure settings
run('figureSettingsDefault.m')

if ees.inputSim.simStart == 0
    simStart = 1; 
else 
    simStart = ees.inputSim.simStart; 
end

maxPower = ees.inputTech.pInverterNom/1e6;

hold(axis, 'on')
grid(axis, 'on'); 
box(axis, 'on');

if simStart == 1
    pStorage    = ees.pStorage/1e6;
    fcrLoad     = ees.fcrData.fcrLoad/1e6;
    idcLoad     = ees.fcrData.idcLoad/1e6;
    frrLoad     = ees.frrData.frrLoad/1e6;
else 
    lengthofVector  = length(ees.pStorage(1:end-1)); 
    pStorage        = ees.pStorage(1:lengthofVector)/1e6;
    fcrLoad         = ees.fcrData.fcrLoad(1:lengthofVector)/1e6;
    idcLoad         = ees.fcrData.idcLoad(1:lengthofVector)/1e6;
    frrLoad         = ees.frrData.frrLoad(1:lengthofVector)/1e6;

end

h.FaceColor      = colors(1,:);

plot(axis, profileTime, pStorage(stepVector)); 

plot(axis, profileTime, fcrLoad(stepVector)); 

plot(axis, profileTime, idcLoad(stepVector)); 

plot(axis, profileTime, frrLoad(stepVector)); 



ylim(axis, [-maxPower, maxPower]);
ylabel(axis, 'Power / MW', textstyle{:});
title(axis, 'Storage Power Flows', textstyle{:});
grid(axis, 'on');
l = legend(axis, 'Total storage power', 'FCR with all degrees of freedom', 'IDC transactions', 'FRR transactions');
set(l, 'Location', 'northwest', textstyle{:});
hold(axis, 'off'); 

end

