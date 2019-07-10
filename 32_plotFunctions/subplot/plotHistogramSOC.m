function [ ] = plotHistogramSOC( ees, ax)
%plotHistogramSOC plots a histogram of the state of charge of ees object.
%   Fct is called by plotAging()
%   Input: agingData - struct with 

%% Get default figure settings
run('figureSettingsDefault.m')

%% Get data
storageSize         = ees.inputTech.eBattNom / 3600; % Watt hours

%% Plot data
hold(ax, 'on');
grid(ax, 'on'); 
box(ax, 'on');

h(1)                = histogram(ax, ees.soc); 
h(1).Normalization  = 'probability';
h(1).BinWidth       = 0.01;

h.FaceAlpha      = .5; 
h.FaceColor      = colors(1,:);

xlim(ax, [0 1]);
set(ax,'LooseInset',get(gca,'TightInset'))

% axis.XTickLabel = axis.XTick * 100;

xlabel(ax, 'State of charge / %', textstyle{:})

xInPercentage = cellstr(num2str((ax.XTick)'*100)); 
new_xTicks = [char(xInPercentage)];
xticklabels(ax, new_xTicks);

ylabel(ax, 'Relative frequency', textstyle{:});

% p(1) = plot(ax, 0, 0,'' , 'Color', [1 1 1], 'LineWidth',0.1);
% legendEntriesComplete{1} = [num2str(storageSize / 1000), ' kWh'];

% l = legend([p(1); h(:)], ['Storage size'; legendEntriesComplete(1:1:end)']);
% set(l, 'Location', 'NorthEast', 'interpreter', 'none')        

% breakyaxis(axis, [0.01 0.45]); 

hold(ax, 'off'); 

end

