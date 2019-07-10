function [ ] = plotBufferStorageProfile( ees, varargin )
% plotBufferStorageProfile plots the power profile of the residential case
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

addParameter(p, 'timeFrame', defVal); 
addParameter(p, 'timeUnit', defVal, @(x) any(validatestring(x, expectedTimeUnit))); 
addParameter(p, 'figureNo', defVal); 
addParameter(p, 'axis', defVal); 

parse(p, varargin{:}); 

timeFrame = p.Results.timeFrame;
timeUnit  = p.Results.timeUnit;
figureNo  = p.Results.figureNo; 
axis  = p.Results.axis; 

inputSim    = ees.inputSim;
tSample = inputSim.tSample;

% Collection of data that is later plotted. Also adjustment to match the
% desired orientation in the plot
bufferStorageData.load            = ees.inputProfiles.load;
%bufferStorageData.generation      = -1 * EES.inputProfiles.generation; 
%bufferStorageData.netLoad         = EES.inputProfiles.load; % - EES.inputProfiles.generation;
% The following three need to be stacked on top of each other in the plot
bufferStorageData.gridPower       = ees.pGrid(:);
bufferStorageData.powerStorage    = -1 * ees.pStorage(:); 
bufferStorageData.curtailPower    = -1 * ees.pCurtail(:); 

if length(timeFrame) == 1
    timeFrame = repmat(timeFrame, 1, 2); 
end 

stepsBefore = inputSim.simStart / tSample; 
% Define index vector with simulation steps
stepVector = (1:ees.kNow-1) + stepsBefore;
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

if inputSim.simStart == 0
    simStart = 1; 
else
    simStart = inputSim.simStart; 
end


%% Prepare figure
if(~ishandle(axis))
    fig1 = figure(figureNo);
    axis   = subplot(1,1,1);   % aging over time
end

hold(axis, 'on'); 
grid(axis, 'on'); 
box(axis, 'on');

fields = fieldnames(bufferStorageData); 

% fields = {'load','generation','gridPower','powerResidual','powerStorage', 'curtailPower'};

%matrix containing rgb values that are used for coloring the curves
rgbMatrix = [0.4  0.4  0.4; % Consumption
               0    0  0.6; % Grid
               0  0.5    0; % BufferStorage
               1  0.6    0; % curtailment
               0    0  0.9; % Storage Power
             0.8    0    0; % Unfulfilled Power
             0.8  0.8  0.8  % Storage Power Operation
             ];
%% Plot data
for i=1:4
    displayName = fields{i}; 

% For when simulation start is not at day 0, these lines were implemented.
% Due to changes in data structure, not guaranteed to work. => Needs to be
% tested.

%     if simStart ~= 1
%         lengthOfVector = length(bufferStorageData.(fields{i})(simStart/sampleTime:end-1)); 
%         bufferStorageData.(fields{i}) = bufferStorageData.(fields{i})(1:lengthOfVector); 
%     else
%         bufferStorageData.(fields{i}) = bufferStorageData.(fields{i})(1:end-1);  
%     end

    if strcmp(displayName, {'load'}) % Plot bus load as a line
        h(i) = plot(axis, profileTime, bufferStorageData.(fields{i})(stepVector) / 1e3, 'LineWidth', 2); 
        h(i).Color = rgbMatrix(i,:);
        uistack(h(i),'top');
%     elseif strcmp(displayName, {'load'}) || strcmp(displayName, {'generation'})
%         h(i) = area(axis, profileTime, bufferStorageData.(fields{i})(stepVector) / 1e3, 'EdgeColor', 'none'); 
%         h(i).FaceColor = rgbMatrix(i,:);
    elseif strcmp(displayName, {'powerStorage'}) % Plot power flow of buffer storage
        h(i) = area(axis, profileTime, bufferStorageData.(fields{i})(stepVector) / 1e3, 'LineWidth', 0.5); 
        h(i).FaceColor = rgbMatrix(i,:);
    elseif strcmp(displayName, {'gridPower'}) % Plot net load 
        h(i) = area(axis, profileTime, bufferStorageData.(fields{i})(stepVector) / 1e3, 'LineWidth', 0.5); 
        h(i).FaceColor = rgbMatrix(i,:);
     elseif strcmp(displayName, {'curtailPower'}) % Plot power the storage can`t deliver
        h(i) = area(axis, profileTime, bufferStorageData.(fields{i})(stepVector) / 1e3, 'LineWidth', 0.5); 
        h(i).FaceColor = rgbMatrix(i,:);
%     else
%         h(i:i+2) = area(axis, profileTime, [bufferStorageData.gridPower(stepVector) / 1e3,bufferStorageData.powerStorage(stepVector) / 1e3 bufferStorageData.curtailPower(stepVector) / 1e3], 'EdgeColor', 'none'); 
%         h(i).FaceColor = rgbMatrix(i,:); 
%         h(i+1).FaceColor = rgbMatrix(i+1,:); 
%         h(i+2).FaceColor = rgbMatrix(i+2,:);
    end


end
for i=1:4
    displayName = fields{i};
    if strcmp(displayName, {'load'})
        uistack(h(i),'top');
    end 
end
% for i=1:4
%     displayName = fields{i};
%     if strcmp(displayName, {'load'})
%         uistack(h(i),'top');
%     end 
% end
l = legend(h,'LoadProfile','GridPower','StoragePower','Curtailment','Grid','Storage','Location','NorthWest');
set(l, 'Location', 'NorthEast', textstyle{:})
% ylim([1.05*min(bufferStorageData.loadProfile), 1.05*max(bufferStorageData.loadProfile)]);
xlim(axis, [profileTime(1) profileTime(end)]);
xlabel(axis, ['Time / ' regexprep(timeUnit,'(\<[a-z])','${lower($1)}')], textstyle{:});
title(axis, 'Power / kW', textstyle{:});
set(axis,'YDir','reverse');

hold off;

end

