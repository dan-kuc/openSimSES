%%  plotProfiles_IS2 
%
% Overview Plot of the profiles in axis handle 'axis'
% Plots ResidualLoad, Storage Power, Diesel Power and Check Load. Unit of time can be
% changed with parameter 'timeUnit'. Period of time to be shown can be
% determined with 'timePeriod', [begin, end] with according unit.
%
% function owner: Manuel Binder
% creation date: 02.03.2017
%
%%



function [ h ] = plotProfiles_IS2( ees, axis, varargin )

% input parser to handle input parameters
p = inputParser;

% default values for parameters
timePeriod          = [ees.inputSim.simStart,ees.inputSim.simEnd] /3600/24;
timeUnit            = 'days';
expectedTimeUnit    = {'seconds', 'minutes', 'hours', 'days', 'years'};

addParameter(p, 'timePeriod', timePeriod);
addParameter(p, 'timeUnit', timeUnit, @(x) any(validatestring(x,expectedTimeUnit)));

parse(p,varargin{:});

timePeriod  = p.Results.timePeriod;
timeUnit    = p.Results.timeUnit;

lTimeArr    = length(ees.SOC);
profileTime = linspace(0, timePeriod(end), lTimeArr);

% % calculate according time vector for x-axis
% switch timeUnit
%     case 'years'
%         profileTime = (EES.simStep-1)*EES.sampleTime/3600/24/365;
%     case 'days'
%         profileTime = (EES.simStep-1)*EES.sampleTime/3600/24;
%     case 'hours'
%         profileTime = (EES.simStep-1)*EES.sampleTime/3600;
%     case 'seconds'
%         profileTime = (EES.simStep-1)*EES.sampleTime;
%     case 'minutes'
%         profileTime = (EES.simStep-1)*EES.sampleTime/60;
%     otherwise
%         disp('plotProfiles: Chosen timeUnit not possible.')
% end

% curtailmentLoss = -EES.powerStorage + EES.power2Grid - (EES.profileConsumption-EES.profileGeneration);
% netLoad = EES.profileConsumption-EES.profileGeneration;
pNet = ees.inputProfiles.load - (ees.inputProfiles.genPV + ees.inputProfiles.genWind);

hold(axis, 'on')
h(1) = plot(axis, profileTime, pNet, 'k', 'LineWidth', 1.2);                                                   
h(2) = area(axis, profileTime, -(ees.pStorage),'EdgeColor','none');                                                          % generation profile PV + Wind
h(3) = area(axis, profileTime, ees.pDiesel,'EdgeColor', 'none');
h(4) = area(axis, profileTime, ees.flagCheckLoad,'EdgeColor','none');
h(5) = plot(axis, profileTime, ees.pLoadLoss, 'm', 'LineWidth', 1.2);
%h(4:7) = area(axis, profileTime', [EES.power2Grid,  EES.checkLoad,-EES.powerStorage, EES.dieselPower], 'EdgeColor','none');  % stacked areas of net load ( storage power, power to grid, curtailment losses, storage operation consumption )
%    h(1).FaceColor = [.4 .4 .4];
    h(2).FaceColor = [0 0 0.9];
    h(3).FaceColor = [.1 .8 .8];
    h(3).FaceAlpha = 0.3;
    h(4).FaceColor = [.8 0 0];
    h(3).FaceAlpha = 0.4;
xlim(axis, [timePeriod(1), timePeriod(end)]);
%set(axis,'YDir','reverse');
hold(axis, 'off')
grid(axis, 'on')
legend(h,'residualLoad','Storage Power','dieselPower','checkLoad','powerLoss')
ylabel(axis,'Power [W]');
xlabel(axis,'Time [s]');
% legend('boxoff')




end