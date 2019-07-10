function [ ] = plotPowerFcrResidential( ees, axis, profileTime, stepVector )
%plotSOCandSOH plots the SOC and the SOH of the storage into one plot. Is
%called by plotStorageData()
%
% INPUTS 
%   ees: Storage object (obligatory)
%   axis: axis handle
%   profileTime
%   stepVector
% OUTPUTS: none
% STATUS: functioning
% LAST UPDATED: 11.03.2019
% OWNER: Markus Förstl

%% Get default figure settings
run('figureSettingsDefault.m')

if ees.inputSim.simStart == 0
    simStart = 1; 
else 
    simStart = ees.inputSim.tSample; 
end

tSample = ees.inputSim.tSample; 



hold(axis, 'on'); 
grid(axis, 'on'); 
box(axis, 'on');

fcrResidentialData.powerApp   =  ees.powerAppAssigned()'; 
fcrResidentialData.powerStorage    = 1 * ees.pStorage(:); 

h(1) = plot(axis, profileTime, fcrResidentialData.powerStorage(stepVector), 'LineWidth', 0.7); 
%size(fcrResidentialData.powerApp,1) anzahl zeile 2*86400 ==>2
for i=1:size(fcrResidentialData.powerApp,1)
    h(1+i)=plot(axis,profileTime,fcrResidentialData.powerApp(i, 1:end),'LineWidth', 1);
end
h(1).Color =[1 0 0]; % max Power magneta
h(2).Color =[1 0 1]; % loadout red
h(3).Color =[0 0 1];
l = legend(axis,'Power @ BESS','Power for FCR','Börse','Location','NorthWest');
set(l, 'Location', 'NorthEast', textstyle{:})
% ylim(axis,[1.05*min(psData.loadProfile), 1.05*max(psData.loadProfile)]);
xlim(axis,[profileTime(1) profileTime(end)]);
% xlabel(['Time in ' regexprep(timeUnit,'(\<[a-z])','${upper($1)}')], textstyle{:}); 
title(axis,'Power in Watts', textstyle{:});
% set(gca,'YDir','reverse');

hold off;

end

