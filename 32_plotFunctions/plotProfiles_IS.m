%%  plotProfiles_IS 
%
% Overview Plot of the profiles in axis handle 'axis'
% Plots generation, consumption and residualLoad. Unit of time can be
% changed with parameter 'timeUnit'. Period of time to be shown can be
% determined with 'timePeriod', [begin, end] with according unit.
%
% function owner: Manuel Binder
% creation date: 02.03.2017
%
%%



function [ h ] = plotProfiles_IS( ees, axis, varargin )

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

% calculate according time vector for x-axis
% switch timeUnit
%     case 'years'
%         profileTime = (ees.simStep-1)*ees.sampleTime/3600/24/365;
%     case 'days'
%         profileTime = (ees.simStep-1)*ees.sampleTime/3600/24;
%     case 'hours'
%         profileTime = (ees.simStep-1)*ees.sampleTime/3600;
%     case 'seconds'
%         profileTime = (ees.simStep-1)*ees.sampleTime;
%     case 'minutes'
%         profileTime = (ees.simStep-1)*ees.sampleTime/60;
%     otherwise
%         disp('plotProfiles: Chosen timeUnit not possible.')
% end

% curtailmentLoss = -EES.powerStorage + EES.power2Grid - (EES.profileConsumption-EES.profileGeneration);
% netLoad = EES.profileConsumption-EES.profileGeneration;
pNet = ees.inputProfiles.load - (ees.inputProfiles.genPV + ees.inputProfiles.genWind);


hold(axis, 'on')
h(1) = area(axis, profileTime, ees.inputProfiles.load, 'EdgeColor','cyan');                                                         % consumption profile of prosumer
h(2) = area(axis, profileTime, -(ees.inputProfiles.genPV+ees.inputProfiles.genWind),'EdgeColor','blue');     % generation profile PV + Wind

h(3) = plot(axis, profileTime, pNet, 'k', 'LineWidth', 1.2);                                                                     % residualLoad
 %h(4:7) = area(axis, profileTime', [EES.power2Grid,  EES.checkLoad,-EES.powerStorage, EES.dieselPower], 'EdgeColor','none');  % stacked areas of net load ( storage power, power to grid, curtailment losses, storage operation consumption )
    h(1).FaceColor = [.4 .4 .4];
    h(2).FaceColor = [.9 .9 0];
  %  h(4).FaceColor = [0 .7 0];
  %  h(5).FaceColor = [.8 0 0];
  %  h(6).FaceColor = [0 0 0.9];
  %  h(7).FaceColor = [.6 .1 .8];
xlim(axis, [timePeriod(1), timePeriod(end)]);
%set(axis,'YDir','reverse');
hold(axis, 'off')
grid(axis, 'on')
legend(h,'Consumption','Generation PV+Wind','residualLoad')
ylabel(axis,'Power [W]');
xlabel(axis,'Time [s]');
% legend('boxoff')




end
