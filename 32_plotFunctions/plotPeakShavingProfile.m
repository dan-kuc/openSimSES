function [h ] = plotPeakShavingProfile( ees, axis, profileTime, stepVector )
% plotPeakShavingProfile plots the power profile of the ps case
%
%   2019-05-12 Stefan Englberger

%% Get default figure settings
run('figureSettingsDefault.m')

% Collection of data that is later plotted. Also adjustment to match the
% desired orientation in the plot
% if-cases needed for standalone PS application
psData.load            = ees.inputPSProfiles.load;

% Decision multi-use or single-use
switch ees.inputSim.scenario
    case 'peak shaving'
         psData.loadout         = ees.pPSGrid;  
    case 'multi-use fcr peak shaving'
         psData.loadout     = ees.powerGridMultiUse;   
end

% The following three need to be stacked on top of each other in the plot
psData.powerStorage    = ees.pStorage(:); 
psData.maxPower        = ees.inputTech.pPeakShaveThresh;

%fcrResidentialData.powerApp   =  ees.powerAppAssigned()'; 
%fcrResidentialData.powerStorage    = 1 * ees.pStorage(:); 


if ees.inputSim.simStart == 0
    simStart = 1; 
else
    simStart = ees.inputSim.simStart; 
end

tSample = ees.inputSim.tSample;     

%% Prepare figure
% fig1 = figure(figureNo); 
hold(axis, 'on')
grid(axis, 'on'); 
box(axis, 'on');
fields = fieldnames(psData); 

%matrix containing rgb values that are used for coloring the curves
rgbMatrix = [0.6000 0.6000 0.6000; % Load w/o BESS
             0.3000 0.3000 0.3000; % Load w/ BESS
             0.4000 0.0000 0.0000; % BESS Power
             1.0000 0.0000 0.0000];% Peak-Shave Threshold
            
%% Plot data
for i=1:3
    displayName = fields{i}; 

    if strcmp(displayName, {'load'}) % Plot net load as a line
        h(i) = plot(axis, profileTime, psData.(fields{i})(stepVector), 'LineStyle',':','LineWidth', 1.0); 
        h(i).Color = rgbMatrix(i,:);
    elseif strcmp(displayName, {'loadout'}) 
        h(i) = plot(axis, profileTime, psData.(fields{i})(stepVector), 'LineWidth', 1.0); 
        h(i).Color = rgbMatrix(i,:);
    else
        h(i) = plot(axis, profileTime, psData.(fields{i})(stepVector), 'LineWidth', 0.5); 
        h(i).Color = rgbMatrix(i,:); 
    end
end
h(4)=refline(axis,[0 psData.maxPower]);
h(4).Color = rgbMatrix(4,:); 
h(4).LineStyle = '--';

% h(5) = plot(axis,profileTime,fcrResidentialData.powerApp(1, 1:end),'LineWidth', 1);
% h(6) = plot(axis,profileTime,fcrResidentialData.powerApp(2, 1:end),'LineWidth', 1);
        
l = legend(axis,'Load w/o BESS','Load w/ BESS','BESS Power','PS Threshold', 'Location', 'SouthWest', 'Orientation','horizontal');
set(l, textstyle{:});
% ylim(axis,[1.05*min(psData.loadProfile), 1.05*max(psData.loadProfile)]);
xlim(axis,[profileTime(1) profileTime(end)]);
% xlabel(['Time in ' regexprep(timeUnit,'(\<[a-z])','${upper($1)}')], textstyle{:}); 
title(axis,'Power in Watts', textstyle{:});
% set(gca,'YDir','reverse');

hold off;


end