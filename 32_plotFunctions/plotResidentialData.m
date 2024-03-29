function [ ] = plotResidentialData( ees, varargin )
% plotStorageData plots storage power, SOC, SOH and Heat Maps of the storage power.
% Four plots in one figure. This function calls
% the different plot functions for SOC, SOH and Power.
%
% INPUTS 
%   EES: Storage object (obligatory)
%   figureNo, timeFrame, timeUnit (see below in USAGE)
%
% OUTPUTS: none
%
% USAGE: plotStorageDataSO(
%           EES{<number>}, 
%           'figureNo', <number of figures already plotted + 1>, 
%           'timeFrame', <time frame that is plotted>, 
%           'timeUnit', <desired time unit of x axis>)
%
% STATUS: functioning
% LAST UPDATED: 15.01.2018
%
% OWNER: Markus F�rstl

%% Get default figure settings
run('figureSettingsDefault.m')

%% Prepare input data
global gvarYEARS2SECONDS gvarDAYS2SECONDS

p = inputParser; % Input Parser to handle parameter inputs

% default values in case parameter is not set
expectedTimeUnit    = {'years', 'days', 'hours', 'minutes', 'seconds', ...
                        'year', 'day', 'hour', 'minute', 'second'}; % limiting possible time units

defVal = NaN; 
tPlot0 = [ees.inputSim.simStart, ees.inputSim.simEnd]./gvarDAYS2SECONDS;
timeUnit0 = 'days';
figureNo = 1;

addParameter(p, 'timeFrame', tPlot0); 
addParameter(p, 'timeUnit', timeUnit0, @(x) any(validatestring(x, expectedTimeUnit))); 
addParameter(p, 'figHandle', defVal); 

parse(p, varargin{:}); 

timeFrame = p.Results.timeFrame;
timeUnit  = p.Results.timeUnit;
figHandle  = p.Results.figHandle; 

if isnan(figHandle)
    screensize  = get( groot, 'Screensize' );
    hFig        = figure('Position',[80 20 screensize(3)*0.95 screensize(4)*0.9]);
    set(hFig,'Color','w');
end

if length(timeFrame) == 1
    timeFrame = repmat(timeFrame, 1, 2); 
end 

numberOfDaysSimulated = ceil((timeFrame(2)-timeFrame(1))/gvarDAYS2SECONDS); 

tSample = ees.inputSim.tSample;
stepsBefore = round(ees.inputSim.simStart / tSample); 
% Define index vector with simulation steps
% stepVector = round((1:ees.kNow) + stepsBefore);
stepVector = 1:round(ees.inputSim.simEnd/tSample);
% Limit index vector to time frame of plotting
% stepVector = stepVector(max(timeFrame(1) / tSample,1):max(timeFrame(2) / tSample,1));

switch timeUnit
    case {'years', 'year'}
        timeUnit = 'years';
        profileTime = stepVector*tSample/gvarYEARS2SECONDS;
    case {'days', 'day'}
        timeUnit = 'days';
        profileTime = stepVector*tSample/gvarDAYS2SECONDS;
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

%% Prepare figures
% TODO: Hart gecoded. Variabler gestalten?
fig1 = figure(figureNo); 
set(fig1, 'Units', 'normalized', 'Position', [0.05 0.05 0.85 0.85]); % Set position of figure relatively to screen size

%This is a 3x2 grid of subplots and the plots are visualized as follows (HM is heat map): 
% |..Storage.....Power..|
% |..State ..of.Charge..|
% |...HMres..|..HMpower.|
% Coded hard
ax(1) = subplot(2,1,1); 
ax(2) = subplot(2,1,2); 
% ax(3) = subplot(3,2,5); 
% ax(4) = subplot(3,2,6); 

%% Plot data
% plotStoragePower(ees, ax(1), profileTime, stepVector); % Plot Storage Power
plotResidentialProfile(ees, 'figureNo', figureNo, 'axis', ax(1), 'timeUnit', timeUnit);%, 'timeUnit', timeUnit, 'timeFrame', timeFrame);
plotSOCandSOH(ees, ax(2), profileTime, stepVector); % Plot SOC and SOH

linkaxes([ax(1) ax(2)], 'x'); 
% xlim([ax(1) ax(2)], [profileTime(1) profileTime(end)]);

ax(1).XLim = [profileTime(1) profileTime(end)];
ax(2).XLim = ax(1).XLim; 

xlabel(ax(1), ['Time / ' regexprep(timeUnit,'(\<[a-z])','${lower($1)}')], textstyle{:}); 
xlabel(ax(2), ['Time / ' regexprep(timeUnit,'(\<[a-z])','${lower($1)}')], textstyle{:}); 

% plotHeatMap(ees, ax(3), numberOfDaysSimulated, stepVector, 'plotValue', 'SOC'); 
% plotHeatMap(ees, ax(4), numberOfDaysSimulated, stepVector, 'plotValue', 'pBatt');

hold off; 


end

