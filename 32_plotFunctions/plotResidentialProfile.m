function [ ] = plotResidentialProfile( ees, varargin )
% plotResidentialProfile plots the power profile of the residential case
% including storage power. One plot in one figure.
%
% INPUTS
%   EES object
%   figureNo
%   timeFrame
%   timeUnit
% OUTPUTS: none
%
% USAGE: plotResidentialProfileSO(
%           EES,
%           'figureNo', <number of figures already plotted + 1>, 
%           'timeFrame', <time frame that is plotted>, 
%           'timeUnit', <desired time unit of x axis>)
% 
% STATUS: working
% LAST UPDATED: 15.01.2018
%
% OWNER: Markus Förstl

%% Get default figure settings
run('figureSettingsDefault.m')

global gvarYEARS2SECONDS gvarDAYS2SECONDS 

p = inputParser;

expectedTimeUnit    = {'years', 'days', 'hours', 'minutes', 'seconds', ...
                        'year', 'day', 'hour', 'minute', 'second'}; % limiting possible time units

defVal = NaN; 
tPlot0 = [ees.inputSim.simStart, ees.inputSim.simEnd];
timeUnit0 = 'seconds';
figNo0 = 1;

addParameter(p, 'timeFrame', tPlot0); 
addParameter(p, 'timeUnit', timeUnit0, @(x) any(validatestring(x, expectedTimeUnit))); 
addParameter(p, 'figureNo', figNo0); 
addParameter(p, 'axis', defVal); 

parse(p, varargin{:}); 

timeFrame = p.Results.timeFrame;
timeUnit  = p.Results.timeUnit;
figureNo  = p.Results.figureNo; 
axis        = p.Results.axis; 

simParam    = ees.inputSim;
tSample = ees.inputSim.tSample;
simStart = ees.inputSim.simStart;
% Collection of data that is later plotted. Also adjustment to match the
% desired orientation in the plot
residentialData.load            = ees.inputProfiles.load;
residentialData.generation      = -1 * ees.inputProfiles.genPV; 
residentialData.netLoad         = ees.inputProfiles.load - ees.inputProfiles.genPV;
% The following three need to be stacked on top of each other in the plot
residentialData.gridPower       = ees.pGrid(:);
residentialData.powerStorage    = -1 * ees.pStorage(:); 
residentialData.curtailPower    = -1 * ees.pCurtail(:); 

if length(timeFrame) == 1
    timeFrame = repmat(timeFrame, 1, 2); 
end 

stepsBefore = round(simStart / tSample); 
% Define index vector with simulation steps
% stepVector = (1:ees.kNow-1) + stepsBefore;
stepVector = 1:numel(residentialData.load);
% Limit index vector to time frame of plotting
stepVector = stepVector(max(timeFrame(1) / tSample,1):max(timeFrame(2) / tSample,1));

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

if simParam.simStart == 0
    simStart = 1; 
end

% sampleTime = simParam.sampleTime;     

%% Prepare figure
if(~ishandle(axis))
    fig1 = figure(figureNo);
    axis   = subplot(1,1,1);   % aging over time
end

hold(axis, 'on'); 
grid(axis, 'on'); 
box(axis, 'on');

fields = fieldnames(residentialData); 

% fields = {'load','generation','gridPower','powerResidual','powerStorage', 'curtailPower'};

%matrix containing rgb values that are used for coloring the curves
rgbMatrix = [0.4  0.4  0.4; % Consumption
             0.9  0.9    0; % Generation
               0    0    0; % Net Load
               0  0.7    0; % Unfulfilled Power
               0    0  0.9; % Storage Power
             0.8    0    0; % Curtailment
             0.8  0.8  0.8  % Storage Power Operation
             ];
%% Plot data
for i=1:4
    displayName = fields{i}; 

% For when simulation start is not at day 0, these lines were implemented.
% Due to changes in data structure, not guaranteed to work. => Needs to be
% tested.

%     if simStart ~= 1
%         lengthOfVector = length(residentialData.(fields{i})(simStart/sampleTime:end-1)); 
%         residentialData.(fields{i}) = residentialData.(fields{i})(1:lengthOfVector); 
%     else
%         residentialData.(fields{i}) = residentialData.(fields{i})(1:end-1);  
%     end

    if strcmp(displayName, {'netLoad'}) % Plot net load as a line
        h(i) = plot(axis, profileTime, residentialData.(fields{i})(stepVector) / 1e3, 'LineWidth', 0.5); 
        h(i).Color = rgbMatrix(i,:);
    elseif strcmp(displayName, {'load'}) || strcmp(displayName, {'generation'})
        h(i) = area(axis, profileTime, residentialData.(fields{i})(stepVector) / 1e3, 'EdgeColor', 'none'); 
        h(i).FaceColor = rgbMatrix(i,:);
    else
        h(i:i+2) = area(axis, profileTime, [residentialData.gridPower(stepVector) / 1e3, residentialData.powerStorage(stepVector) / 1e3, residentialData.curtailPower(stepVector) / 1e3], 'EdgeColor', 'none'); 
        h(i).FaceColor = rgbMatrix(i,:); 
        h(i+1).FaceColor = rgbMatrix(i+1,:); 
        h(i+2).FaceColor = rgbMatrix(i+2,:);
    end

end

l = legend(h,'Consumption','Generation','Net load','Grid','Storage','Curtailment','Location','NorthWest');
set(l, 'Location', 'NorthEast', textstyle{:})
% ylim([1.05*min(residentialData.loadProfile), 1.05*max(residentialData.loadProfile)]);
xlim(axis, [profileTime(1) profileTime(end)]);
xlabel(axis, ['Time / ' regexprep(timeUnit,'(\<[a-z])','${lower($1)}')], textstyle{:});
title(axis, 'Power / kW', textstyle{:});
set(axis,'YDir','reverse');

hold off;

end

