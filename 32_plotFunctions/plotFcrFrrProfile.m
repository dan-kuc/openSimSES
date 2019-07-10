%% plotResultsFcrFrr
% 
%   Plotting script for frr / fcr results
%   2018-10-09 Daniel Kucevic
%%

function [  ] = plotFcrFrrProfile( ees, varargin )

%% Get default figure settings
run('figureSettingsDefault.m')

%% Prepare input data
global gvarYEARS2SECONDS gvarDAYS2SECONDS gvarKWH2WS

p = inputParser; % Input Parser to handle parameter inputs

% default values in case parameter is not set
expectedTimeUnit    = {'years', 'days', 'hours', 'minutes', 'seconds', ...
                        'year', 'day', 'hour', 'minute', 'second'}; % limiting possible time units

defVal = NaN; 
tPlot0 = [ees.inputSim.simStart, ees.inputSim.simEnd];
timeUnit0 = 'seconds';
figNo0 = 1;

addParameter(p, 'timeFrame', tPlot0); 
addParameter(p, 'timeUnit', timeUnit0, @(x) any(validatestring(x, expectedTimeUnit))); 
addParameter(p, 'figureNo', figNo0); 

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
stepVector = round((1:ees.kNow) + stepsBefore);
% Limit index vector to time frame of plotting
if ees.inputSim.simStart == 0
    stepVector = stepVector(1:max(timeFrame(2) / tSample,1) - max(timeFrame(1) / tSample,1) + 1);
else
    stepVector = stepVector(1:max(timeFrame(2) / tSample,1) - max(timeFrame(1) / tSample,1));
end
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
stepVector = stepVector - stepsBefore;

%% Prepare figures
fig1 = figure(figureNo); 
set(fig1, 'Units', 'normalized', 'Position', [0.05 0.05 0.85 0.85]); % Set position of figure relatively to screen

%This is a 3x2 grid of subplots and the plots are visualized as follows (HM is heat map): 
% |..........Histogram_C-Rate..........|
% |..............Power.................|
% |..pie_diagramm..|..Additional_Info..|
ax(1) = subplot(3,2,[1,2]); 
ax(2) = subplot(3,2,[3,4]); 
ax(3) = subplot(3,2,5); 
ax(4) = subplot(3,2,6); 
ax(4).Visible = 'off';

%% Plot fcr simulation results
plotHistogramCRate(ees, ax(1)); % Plot Histogram C-Rate
plotPowerFlowsFcrFrr(ees, ax(2), profileTime, stepVector); % Plot relative Power of various transactions (IDC, FRR, FCR)
plotPieFcrFrr(ees, ax(3));

ax(2).XLim = [profileTime(1) profileTime(end)]; 
 

xlabel(ax(2), ['Time / ' regexprep(timeUnit,'(\<[a-z])','${lower($1)}')], textstyle{:}); 

chargedEnergy       = sum(ees.pStorage(ees.pStorage>0))/gvarKWH2WS/1e3;
dischargedEnergy    = abs(sum(ees.pStorage(ees.pStorage<0)))/gvarKWH2WS/1e3;
losses              = chargedEnergy - dischargedEnergy - (ees.soc(end) - ees.soc(1))*ees.inputTech.eBattNom/gvarKWH2WS/1e3;
fec                 = (sum(ees.pBatt(ees.pBatt>0)) + abs(sum(ees.pBatt(ees.pBatt<0))))/2/ees.inputTech.eBattNom;

str{1} = sprintf('SOH: %0.2f %%', ees.sohCapNow*100);
str{2} = sprintf('Charged Energy: %0.2f MWh', chargedEnergy);
str{3} = sprintf('Discharged Energy: %0.2f MWh', dischargedEnergy);
str{4} = sprintf('Losses: %0.2f MWh', losses);
str{5} = sprintf('FEC: %0.2f ', fec);
set(gcf,'CurrentAxes',ax(4));
text(0,0.9,str,textstyle{:});



