function [ ] = plotPeakShave( ees, varargin )
% plotPs plots the power profile of the ps case
% including storage power. One plot in one figure.
%
%   2019-05-12 Stefan Englberger

%% Get default figure settings
run('figureSettingsDefault.m')

%% Prepare input data
global gvarYEARS2SECONDS gvarDAYS2SECONDS

p = inputParser; % Input Parser to handle parameter inputs

% default values in case parameter is not set
expectedTimeUnit    = {'years', 'days', 'hours', 'minutes', 'seconds', ...
                       'year', 'day', 'hour', 'minute', 'second'}; % limiting possible time units

defVal = NaN; 

addParameter(p, 'timeFrame', defVal); 
addParameter(p, 'timeUnit', defVal, @(x) any(validatestring(x, expectedTimeUnit))); 
addParameter(p, 'figureNo', defVal); 

parse(p, varargin{:}); 

timeFrame = p.Results.timeFrame;
timeUnit  = p.Results.timeUnit;
figureNo  = p.Results.figureNo; 

if length(timeFrame) == 1
    timeFrame = repmat(timeFrame, 1, 2); 
end 

numberOfDaysSimulated = ceil((timeFrame(2)-timeFrame(1))/gvarDAYS2SECONDS); 

tSample = ees.inputSim.tSample;

stepsBefore = ees.inputSim.simStart / tSample; 

% Define index vector with simulation steps
stepVector = round((1:ees.tNow) + stepsBefore);
% Limit index vector to time frame of plotting
if ees.inputSim.simStart == 0
    stepVector = stepVector(1:max(timeFrame(2) / tSample,1) - max(timeFrame(1) / tSample,1) + 1);
else
    stepVector = stepVector(1:max(timeFrame(2) / tSample,1) - max(timeFrame(1) / tSample,1));
end
% Crop stepVector to given time frame
stepVector = stepVector - stepsBefore; 

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
hold on;
grid on;
 box on;
set(fig1, 'Units', 'normalized', 'Position', [0.05 0.05 0.85 0.85]); % Set position of figure relatively to screen size

%  This is a 2x1 grid of subplots and the plots are visualized as follows: 
% |PeakShaving|
% |State of Charge|

% Coded hard
ax(1) = subplot(3,1,[1,2]); 
ax(2) = subplot(3,1,3); 


%% Plot data
plotPeakShavingProfile(ees, ax(1), profileTime, stepVector); % Plot Storage Power
plotSOCandSOH(ees, ax(2), profileTime, stepVector); % Plot SOC and SOH

% linkaxes([ax(1) ax(2)], 'x'); 
% xlim([ax(1) ax(2)], [profileTime(1) profileTime(end)]);

ax(1).XLim = [profileTime(1) profileTime(end)];
ax(2).XLim = ax(1).XLim; 

xlabel(ax(1), ['Time in ' regexprep(timeUnit,'(\<[a-z])','${upper($1)}')], textstyle{:}); 
xlabel(ax(2), ['Time in ' regexprep(timeUnit,'(\<[a-z])','${upper($1)}')], textstyle{:}); 


hold off; 


end

