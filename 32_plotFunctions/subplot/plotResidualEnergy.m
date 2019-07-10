function [ ] = plotResidualEnergy( ees, axis, profileTime )
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
    simStart = ees.inputSim.simStart; 
end

tSapmle = ees.inputSim.tSample; 

hold(axis, 'on'); 
grid(axis, 'on'); 
box(axis, 'on');

energyAppResidual= ees.energyAppResidual()';

%%
for i=1:size(energyAppResidual,1)
    h(i)=plot(axis,profileTime,energyAppResidual(i, 1:end));
end

h(1).Color =[1 0 0]; % loadout red
h(2).Color =  [0 0 1  ];

title(axis, 'Residual Energy in Ws',  textstyle{:}); 
l = legend(axis,'Fcr','Residential'); 
set(l, 'Location', 'NorthEast', textstyle{:});
grid(axis, 'on'); 

end

