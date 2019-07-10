function [ h ] = plotStoragePower( ees, axis, profileTime, stepVector)
%plotStoragePower plots the storage power. It is called by
%plotStorageData()

%% Get default figure settings
run('figureSettingsDefault.m')

if ees.inputSim.simStart == 0
    simStart = 1; 
else 
    simStart = ees.inputSim.simStart; 
end

tSample  = ees.inputSim.tSample; 
storageSize = ees.inputTech.eBattNom/3600;
maxCRate = 1/10*ceil(10*max(abs(ees.pStorage))/storageSize);

hold(axis, 'on')
grid(axis, 'on'); 
box(axis, 'on');

if simStart ~=0
    pStorage = ees.pStorage; 
else 
    lengthofVector = length(ees.pStorage(1:end-1)); 
    pStorage = ees.pStorage(1:lengthofVector);
%    stepVector = stepVector(1:end-1);
%     powerBatt = EES.powerBatt(simStart/sampleTime:end-1); 
end

h(1) = area(axis, profileTime, pStorage(stepVector) / storageSize, 'EdgeColor', 'none'); 
h(1).FaceColor = [0 0.2 89/255]; 

% h(2) = area(axis, profileTime, EES.powerStorage, 'EdgeColor', 'none'); 
% h(2).FaceColor =  [1 0 0]; 

ylim(axis, [-maxCRate, maxCRate]);
title(axis, 'Storage E-rate / h^{-1}', textstyle{:});
grid(axis, 'on'); 
hold(axis, 'off'); 

end

