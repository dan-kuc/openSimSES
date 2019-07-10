function [ ] = plotStorageData_v2( ees, varargin )
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
% OWNER: Markus Förstl

%% Get default figure settings
run('figureSettingsDefault.m')

%% Prepare input data
global gvarYEARS2SECONDS gvarDAYS2SECONDS

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
% stepsBefore = ees.inputSim.simStart / tSample;
stepsBefore = timeFrame(1) / tSample;
% Define index vector with simulation steps
stepVector = round((1:ees.kNow) + stepsBefore -1);
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
% stepVector = stepVector - stepsBefore;
stepVector = stepVector;
%% Prepare figures
% TODO: Hart gecoded. Variabler gestalten?
fig1 = figure(figureNo); 
set(fig1, 'units','centimeters','position',[3 3 17 5]); % Set position of figure relatively to screen size

%This is a 3x2 grid of subplots and the plots are visualized as follows (HM is heat map): 
% |..Storage.....Power..|
% |..State ..of.Charge..|
% |...HMres..|..HMpower.|
% Coded hard
% ax(1) = subplot(1,1,1);
% 
% %% Plot data
% plotMultiUseLoadProfile_v2(ees, ax(1), profileTime, stepVector); % Plot Storage Power

%% script
run('figureSettingsDefault.m')

rgbMatrix =  [0.3000 0.7500 0.9000;                         % IDC
             0.0000 0.4470 0.8410;                          % FCR
             0.4940 0.1840 0.5560;                          % PS FTM
             0.0000 0.0000 0.0000;                          % FTM active Power
             0.8500 0.3250 0.0980;                          % PS BTM
             0.9290 0.6940 0.1250;                          % SCI
             0.2660 0.4740 0.1000;                          % qComp
             0.0000 1.0000 0.0000;                          % qAvailable
             0.7000 1.0000 0.0000;                          % qGrid 
             0.0000 0.0000 0.0000;                          % BTM active Power
             0.6000 0.6000 0.6000;                          % Power factor WO QC
             0.0000 0.0000 0.0000;                          % Power factor with QC
             0.6000 0.6000 0.6000;                          % Load WO BESS
             0.3000 0.3000 0.3000];                         % Load with BESS

powerPs     = ees.pStorage(:,1);

LoadWoBess      = ees.inputPSProfiles.load/1000;                        % powerResidual equals load minus generation
LoadWBess       = ees.pPSGrid/1000;           % Load with BESS equals residual power plus PS and SCI power     
pThresh         = ees.inputTech.pPeakShaveThresh/1000;           % Threshhold for PS application
% Define maximum y value
maxLoadWoBess   = max(LoadWoBess);
maxLoadWBess    = max(LoadWBess);
maxLoad         = max(maxLoadWoBess, maxLoadWBess);
maxLoad         = max(maxLoad, pThresh);
% Define minimum y value
minLoadWoBess   = min(LoadWoBess);
minLoadWBess    = min(LoadWBess);
minLoad         = min(minLoadWoBess, minLoadWBess);
minLoad         = min(minLoad, pThresh);

hold('on')
grid('on'); 
box('on');

h(1) = plot(profileTime, LoadWoBess(stepVector));
h(2) = plot(profileTime, LoadWBess(stepVector));
h(3) = refline([0 pThresh]);
h(1).Color = rgbMatrix(13,:);
h(1).LineStyle = ':';
h(2).Color = rgbMatrix(14,:);
h(3).Color = 'r';
h(3).LineStyle = '--';
    
l = legend('Load w/o BESS', 'Load with BESS', 'PS^{threshold}'); 
set(l, 'Location', 'south', 'Orientation','horizontal', 'NumColumns',3, textstyle{:});
set(l.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.85]));

ylim([minLoad, maxLoad]);
ylabel('Residual load / kW', textstyle{:});
grid('on'); 
hold('off'); 

% Create textbox
annotation('textbox',...
	[0.127527216174184 0.782068785591731 0.230171066698724 0.13756613504319],...
	'Color',[1 0 0],...
	'String',{['PS^{threshold} = ',num2str(round(pThresh,0)),' kW']},...
	'EdgeColor','none');

% Create arrow
annotation('arrow',[0.135303265940902 0.105754276827372],...
	[0.803232804232804 0.719576719576719],'Color',[1 0 0],'HeadWidth',7,...
	'HeadLength',7);

%%
% 
% linkaxes([ax(1)], 'x'); 
% xlim([ax(1) ax(2)], [profileTime(1) profileTime(end)]);

% ax(1).XLim = [profileTime(1) profileTime(end)];


% xlabel(ax(1), ['Time / ' regexprep(timeUnit,'(\<[a-z])','${lower($1)}')], textstyle{:});
xlim([profileTime(1) profileTime(end)]);
xlabel(['Time / ' regexprep(timeUnit,'(\<[a-z])','${lower($1)}')], textstyle{:});

set(findall(gcf,'-property','FontSize'),'FontSize',10);
set(findall(gcf,'-property','FontName'),'FontName','Palatino Linotype');

set(gca,'LooseInset',get(gca,'TightInset')); a = get(gca,'Position'); set(gca,'Position',[a(1)+0.005 a(2) a(3)-0.010 a(4)-0.005]);

hold off;

end

