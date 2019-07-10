function [ ] = plotSOCandSOH( ees, axis, profileTime, stepVector )
%plotSOCandSOH plots the SOC and the SOH of the storage into one plot. Is
%called by plotStorageData()
%
% INPUTS 
%   EES: Storage object (obligatory)
%   axis: axis handle
%   profileTime
%   stepVector
% OUTPUTS: none
% STATUS: functioning
% LAST UPDATED: 15.01.2018
% OWNER: Markus Förstl

%% Get default figure settings
run('figureSettingsDefault.m')

if ees.inputSim.simStart == 0
    simStart = 1; 
else 
    simStart = ees.inputSim.simStart; 
end

tSample = ees.inputSim.tSample; 

if simStart ~= 0
    soc = ees.soc; %Plot it in percent. => Multiplication with 100
%     SOH = EES.batteryEnergyRemain ./ EES.technicalData.batteryNominalEnergy; 
%     soh = ees.sohCap;
    
else 
    lengthofVector = length(ees.soc(1:end-1)); 
    soc = ees.soc(1:lengthofVector); 
%     SOH = EES.batteryEnergyRemain(1:lengthofVector) ./ EES.technicalData.batteryNominalEnergy; 
%     soh = ees.sohCap(1:lengthofVector);

end

% We want to plot it in percent, hence * 100
soc = soc * 100; 
% soh = soh * 100; 

hold(axis, 'on'); 
grid(axis, 'on'); 
box(axis, 'on');

% SOC corresponds to left y-axis
yyaxis(axis, 'left')
h(1) = plot(axis, profileTime, soc(stepVector)); 
h(1).Color = colors(1,:);
ylabel('SOC / %');
ylim(axis, [0, 100]);

    
    % SOH corresponds to the right y-axis 
%     yyaxis(axis, 'right')
%     h(2) = plot(axis, profileTime, soh(stepVector)); 
%     ylim(axis, [.999 * min(soh(stepVector)), 100]);
%     ylabel('SOH / %');
%     l = legend(axis, 'SOC', 'SOH'); 
%     set(l, 'Location', 'northwest', textstyle{:});
    grid(axis, 'on')


end

