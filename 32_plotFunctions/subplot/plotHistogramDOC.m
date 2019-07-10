function [ ] = plotHistogramDOC( ees, ax)
%plotHistogramDOC plots a histogram of the DOC of ees object.
%   Fct is called by plotAging()
%   Input:  ees object
%           axis: specified axis in subplot
%           figureSettings: struct for formatting

%% Get default figure settings
run('figureSettingsDefault.m')

%% Get data
storageSize = ees.inputTech.eBattNom / 3600; % Watt hours
[~, DOC]    = calcCRateDOC(ees); 
maxDOC      = ceil(max(abs(DOC)));

%% Plot data
hold(ax, 'on');
grid(ax, 'on'); 
box(ax, 'on');

h(1)                = histogram(ax, DOC(DOC~=0)); 
h(1).BinEdges       = [-1:0.05:1];
h(1).Normalization  = 'probability';

h.FaceAlpha      = .5; 
h.FaceColor      = colors(1,:);

% ylim(axis, [0 0.01]); 
xlim(ax, [-maxDOC maxDOC]);     

set(ax,'LooseInset',get(ax,'TightInset'))

xlabel(ax, 'Cycle depth / %', textstyle{:})
xInPercentage = cellstr(num2str((ax.XTick)'*100)); 
new_xTicks = [char(xInPercentage)];
xticklabels(ax, new_xTicks);
ylabel(ax, 'Relative frequency', textstyle{:});

end

