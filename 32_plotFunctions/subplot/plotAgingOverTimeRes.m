function [ ] = plotAgingOverTimeRes(ees, ax, varargin)
%   plotAgingOverTimeRes plots the aging of the resistance of the storage into one plot. 
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
stepsBefore = ees.inputSim.simStart / tSample; 
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
changeResCal         = 100 * ees.resistanceChangeCalendric;
changeResCyc         = 100 * ees.resistanceChangeCyclic;
changeResTot         = 100 * ees.resistanceChangeTotal;

%% Plot figure
hold(ax, 'on'); 
grid(ax, 'on'); 
box(ax, 'on');

h(1) = plot(ax, profileTime, cumsum(changeResTot),  plotstyles{1}{:}, 'Color', colors(2,:)); 
h(2) = plot(ax, profileTime, cumsum(changeResCal),  plotstyles{2}{:}, 'Color', colors(2,:)); 
h(3) = plot(ax, profileTime, cumsum(changeResCyc),  plotstyles{3}{:}, 'Color', colors(2,:)); 

ax.XLim = [profileTime(1) profileTime(end)]; 
xlabel(ax, ['Time / ' regexprep(timeUnit,'(\<[a-z])','${lower($1)}')], textstyle{:});
ylabel(ax, 'Resistance increase / %', textstyle{:}); 
l = legend(ax,...
    'Resistance increase (total)',...
    'Resistance increase (calendar)',...
    'Resistance increase (cycle)', ....
    'Location', 'northwest');
set(l, textstyle{:},'FontSize',fontsize);
hold(ax, 'off'); 

%axis.YLim = [1.01 * min(ees.capacityChangeTotal), 200];

end

