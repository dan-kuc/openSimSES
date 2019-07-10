function [ ] = plotHistogramCRate( ees, ax )
%plotHistogramCRate plots a histogram of the C-rate of ees object.
%   Fct is called by plotAging()
%   Input:  ees object
%           axis: specified axis in subplot
%           figureSettings: struct for formatting

%% Get default figure settings
run('figureSettingsDefault.m')

%% Get data from ees object
pStorage       =    ees.pStorage; % Watt
storageSize    =    ees.inputTech.eBattNom / 3600; % Watt hours

% Round maxCRate to first decimal places to adjust limits of x axis
Ndecimals           = 1; 
f                   = 10.^Ndecimals; 
maxCRate            = ceil(f*max(abs(pStorage))/storageSize(1)) / f;
NBins               = 20;
%% Plot data
hold(ax, 'on'); 
grid(ax, 'on'); 
box(ax, 'on'); 

h                = histogram(ax, pStorage./storageSize(1)); 
h.BinEdges       = -maxCRate:maxCRate/NBins:maxCRate;
h.Normalization  = 'probability';

h.FaceAlpha      = .5; 
h.FaceColor      = colors(1,:);

xlim(ax, [-maxCRate maxCRate]);     

set(ax,'LooseInset',get(gca,'TightInset'))
title(ax, 'Histogram Storage Power', textstyle{:});
xlabel(ax, 'C-rate / h^{-1}', textstyle{:})
ylabel(ax, 'Relative frequency', textstyle{:});

% p = plot(ax, 0, 0, 'Color', [1 1 1], 'LineWidth',0.1);
% legendEntriesComplete{1} = [num2str(storageSize / 1000), ' kWh'];

% l = legend([p(1); h(:)], ['Storage size'; legendEntriesComplete(1:1:end)']);
% set(l, 'Location', 'NorthEast', 'interpreter', 'none')

hold(ax, 'off'); 

end

