function [ ] = plotHistogramCRateDOC( ees, ax )
%plotHistogramCRateDOC plots a histogram of the C-rate over DOC of ees object.
%   Fct is called by plotAging()
%   Input:  ees object
%           axis: specified axis in subplot
%           figureSettings: struct for formatting

%% Get default figure settings
run('figureSettingsDefault.m')

%% Get data
storageSize = ees.inputTech.eBattNom / 3600; % Watt hours
[avgCRate, DOC] = calcCRateDOC(ees); 
maxDOC          = ceil(max(abs(DOC)));
NBins           = 10;

%% Plot data
% hold(ax, 'on');
grid(ax, 'on'); 

h                = histogram2(ax, DOC, avgCRate, 'FaceColor', 'flat', 'FaceAlpha', 0.85);
h.Normalization  = 'probability';

colormap(parula);
colorbar

% hard coded. to do: find solution 

Ndecimals           = 1; 
f                   = 10.^Ndecimals; 
maxCRateRounded     = ceil(f*max(abs(ees.pStorage))/storageSize) / f;  
h.XBinEdges = [-1:1/NBins:1]; 
h.YBinEdges = [-maxCRateRounded:maxCRateRounded/NBins:maxCRateRounded];
% h.BinWidth = [0.1 0.1];
xlim([-maxDOC maxDOC]); % Depth of Cycle limits
ylim([-maxCRateRounded maxCRateRounded]); % C-Rate limits

% set(ax,'LooseInset',get(gca,'TightInset'))

xlabel(ax, 'Cycle depth / %', textstyle{:})
xInPercentage = cellstr(num2str((ax.XTick)'*100)); 
new_xTicks = [char(xInPercentage)];
xticklabels(ax, new_xTicks);

ylabel(ax, 'C-rate / h^{-1}',  textstyle{:})
zlabel(ax, 'Relative frequency', textstyle{:});

%% Matlab does not support logarithmic colorbars. Workaround.
% https://stackoverflow.com/questions/45398496/how-can-i-display-a-log-scale-colorbar-with-matlab-r2015a
% 
% cbar = colorbar; % create colorbar
% z = h.Values; % get histogram values
% 
% pause(1e-3); axpos = ax.Position; pause(1e-3); % get position of subplot (for future use)
% 
% dummyAx = axes('Position', [0 0 0 0]); %create new dummy axis
% set(dummyAx, 'Layer', 'bottom'); 
% % axis off; 
% 
% cb = colorbar('Position', cbar.Position); % create new colorbar on top of the original colorbar
% delete(cbar); % delete colorbar
% 
% caxis(log10([min(z(z>0)) max(z(:))])) %update ticks and limits of colorbar
% cb.TickLabels = sprintf('10^{%1.1f}\n', cb.Ticks); % label the limits to logarithmic scale
% 
% %  
% box(ax, 'on');
% set(ax, 'Position', axpos); %set position of axes so that colorbar is next to the plot
% cla(dummyAx);

% title(ax, {['Frequency distribution of C-rate over cycle depth']}, textstyle{:}); 
view(ax, [45 75]);

hold(ax, 'off'); 

end

