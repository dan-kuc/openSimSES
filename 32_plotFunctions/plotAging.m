function [ ] = plotAging( ees, varargin )
%plotAging is plotting the aging data (histograms and course of time of
%aging)
%   Input:  ees object
%           timeUnit: time unit for plots of course of time
%           figureNo: number of figure
%           scaleYAxis: possible values: 'linear', 'log' determines the
%           scale of the ordinate in histograms
%   Output: none
%   Example usage: [] = plotAgingMF(ees, 'figureNo', 1, 'timeUnit', 'days',
%                                   'scaleYAxis', 'linear'); 
% 
%   Last updated: 2018-01-15 Förstl, Naumann

%% Get default figure settings
run('figureSettingsDefault.m')

%% Prepare input data
p       = inputParser; 
expectedTimeUnit    = {'years', 'days', 'hours', 'minutes', 'seconds', ...
                        'year', 'day', 'hour', 'minute', 'second'}; % limiting possible time units
expectedYScale      = {'linear', 'log'};
defVal  = NaN; 
 
addParameter(p, 'timeUnit', defVal, @(x) any(validatestring(x, expectedTimeUnit))); 
addParameter(p, 'figureNo', defVal);
addParameter(p, 'scaleYAxis', defVal, @(x) any(validatestring(x, expectedYScale)));

parse(p, varargin{:}); 
timeUnit    = p.Results.timeUnit; 
figureNo    = p.Results.figureNo; 
scaleYAxis  = p.Results.scaleYAxis; 

%% Prepare figure
fig1    = figure(figureNo); 
set(fig1, 'Units', 'normalized', 'Position', [0.05 0.02 0.90 0.90]); % Set position of figure relatively to screen size

% Create a 3x2 grid of subplots whose plots are arranged as follows
%  _________________________________
% |                                 |
% |__aging(calendric,cycle,total)___|
% |_____ C-Rate_____|______DOC______|  
% |________________SOC______________| 
% |_________________________________|

ax(1)   = subplot(3,2,[1,2]);   % aging over time

if ~(max(ees.resistanceChangeTotal) == 0) 
    for i=1:4
        ax(i) = subplot(3,2,i); % create six plots 2 x 2 x 2 and plot resistance change in extra subplot            
    end
	ax(5) = subplot(3,2,[5,6]); % SOC

else
    ax(1) = subplot(3,2,[1,2]); % do not plot resistance change if it does not exist and stretch aging over time-plot over whole row
    ax(2) = subplot(3,2,3);     % C-Rate
    ax(3) = subplot(3,2,4);     % DOD
    ax(4) = subplot(3,2,[5,6]); % SOC
end
                        
%% Call plotting functions
if ~(max(ees.resistanceChangeTotal) == 0) 
    plotAgingOverTimeCap(ees, ax(1), 'timeUnit', timeUnit);    % Plot aging over time
    plotAgingOverTimeRes(ees, ax(2), 'timeUnit', timeUnit);    % Plot aging over time
    plotHistogramCRate(ees, ax(3)); 
    plotHistogramDOC(ees, ax(4)); 
    plotHistogramSOC(ees, ax(5));                           % Plot Depth of Cycle Histogram
    
    for i=3:numel(ax)
        set(ax(i), 'YScale', scaleYAxis); 
    end
else
    plotAgingOverTimeCap(ees, ax(1), 'timeUnit', timeUnit);
    plotHistogramCRate(ees, ax(2));                         % Plot C-Rate Histogram
    plotHistogramDOC(ees, ax(3));                           % Plot SOC Histogram
    plotHistogramSOC(ees, ax(4));                           % Plot Depth of Cycle Histogram    
    for i=2:numel(ax)
        set(ax(i), 'YScale', scaleYAxis); 
    end
end

titleOfFigure = ['Storage aging data']; 

annotation('textbox', [0 0.87 1 0.1], textstyle{:}, 'FontSize', 16, 'FontWeight', 'bold', ...
    'String', titleOfFigure, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center')

%% Plot 3D Histogram of C rate over DOC in own figure for better visibility
fig2 = figure(figureNo + 1);
set(fig2, 'Units', 'normalized', 'Position', [0.3 0.3 0.60 0.5]); % Set position of figure relatively to screen size
plotHistogramCRateDOC(ees, gca); 
set(gca,  'ZScale', scaleYAxis);

end

