function [ ] = plotAgingOverTimeCap(ees, ax, varargin)
%   plotAgingOverTimeCap plots the aging of the capacity of the storage into one plot. 
%   Fct is called by plotAging()
%   Input:  ees object
%           axis: specified axis in subplot
%           figureSettings: struct for formatting

%% Get default figure settings
run('figureSettingsDefault.m')

%% Prepare input data
p = inputParser; 

% Default values in case parameter is not set
expectedTimeUnit    = {'years', 'days', 'hours', 'minutes', 'seconds', ...
                        'year', 'day', 'hour', 'minute', 'second'}; % limiting possible time units

defVal = ees.inputSim.plotTimeUnit;
% defAxis = NaN; 
addParameter(p, 'timeUnit', defVal, @(x) any(validatestring(x, expectedTimeUnit))); 

parse(p, varargin{:}); 
timeUnit = p.Results.timeUnit; 

tSample = ees.inputSim.tSample;
simStart = ees.inputSim.simStart;
stepsBefore = simStart / tSample;
stepVector  = (1:ees.kNow-1) + stepsBefore; 

switch timeUnit
    case {'years', 'year'}
        timeUnit = 'years';
        profileTime = stepVector*tSample/(3600*24*365);
    case {'days', 'day'}
        timeUnit = 'days';
        profileTime = stepVector*tSample/(3600*24);
    case {'hours', 'hour'}
        timeUnit = 'hours';
        profileTime = stepVector*tSample/3600;
    case {'minutes', 'minute'}
        timeUnit = 'minutes';
        profileTime = stepVector*tSample/60;
    case {'seconds', 'second'}
        timeUnit = 'seconds';
        profileTime = stepVector*tSample;
    otherwise 
        disp('plotResults: Chosen timeUnit not possible.')
end

%% Prepare data
eBattNom                = ees.inputTech.eBattNom;
changeCapCalRelative    = 100 * ees.capacityChangeCalendric  / eBattNom; % in percent
changeCapCycRelative    = 100 * ees.capacityChangeCyclic     / eBattNom;
changeCapTotRelative    = 100 * ees.capacityChangeTotal      / eBattNom; 

%% Plot figure
hold(ax, 'on'); 
grid(ax, 'on'); 
box(ax, 'on');

% plot capacity loss to the left. 
h(1) = plot(ax, profileTime, -1 * cumsum(changeCapTotRelative), plotstyles{1}{:}, 'Color', colors(1,:)); 
h(2) = plot(ax, profileTime, -1 * cumsum(changeCapCalRelative), plotstyles{2}{:}, 'Color', colors(1,:)); 
h(3) = plot(ax, profileTime, -1 * cumsum(changeCapCycRelative), plotstyles{3}{:}, 'Color', colors(1,:)); 

ax.XLim = [profileTime(1) profileTime(end)]; 
xlabel(ax, ['Time / ' regexprep(timeUnit,'(\<[a-z])','${lower($1)}')], textstyle{:});
ylabel(ax, 'Capacity loss / %', textstyle{:});
l=legend(ax, 'Capacity loss (total)', ...
    'Capacity loss (calendar)',...
    'Capacity loss (cycle)',...
    'Location', 'northwest');
set(l, textstyle{:},'FontSize',fontsize);
hold(ax, 'off'); 

%axis.YLim = [1.01 * min(ees.capacityChangeTotal), 200];

end

