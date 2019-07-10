%% NMC_Tesla_DailyCyclePowerwall_CalAging: Calendric aging model
% 
% Script to define function for an aging model 
% Cell type:    Tesla Powerwall NMC / Panasonic NCA
% Aging model:  Tesla Daily Cycle Powerwall
% Model type:   Datasheet fit
% Model source: Powerwall manufacturers warranty certificate (Germany): 1073253-00-A, 22.01.2016
% Stress values:
%   time1       % [s] Start point of time of aging 
%   time2       % [s] End point of time of aging
%
% Output values: AgingCalendric
%   agingCalendric.relCapacityChange    % [pu]
%   agingCalendric.relResistanceChange  % [pu]
%
% Function owner: Maik Naumann
% Creation date: 02.03.2016
%
%%
function agingCalendric = NMC_Tesla_DailyCyclePowerwall_CalAging(agingStress, ~, ~, sampleTime, ~, ~)

%% Input assignment
time1           = agingStress.cumAgingTime;
time2           = agingStress.cumAgingTime + sampleTime;

%% Calculate calendric aging

% Calculation calendric capacity change with exponential function fitted on data of warranty sheet:
% Time / years | SOH / 0-1: [0 1.00; 2 0.85; 5 0.72; 10 0.6]
% Valid for 25°C ambient and battery temperature for SOH-estimation with 2 kW
% 
% General model Exp2:
%      f(x) = a*exp(b*x) + c*exp(d*x)

% Set up fittype and options.
% ft = fittype( 'exp2' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [0.18476018013638 -1.14303513597413e-08 0.81523981986363 -9.98739794280851e-10];

% Goodness of fit:
%   SSE: 1.613e-05
%   R-square: 0.9998
%   Adjusted R-square: NaN
%   RMSE: NaN

% Coefficients
a =      0.2732;
b =   1.329e-09;
c =     -0.2721;
d =  -9.618e-09;

% Calculate relative capacity fade
agingCalendric.relCapacityChange    = -(a*exp(b*(time2)) + c*exp(d*(time2)) - ...
                                       (a*exp(b*(time1)) + c*exp(d*(time1))));  % [pu]

% Calculate resistance increase
% Resistance change is not reflected in this model
agingCalendric.relResistanceChange  = 0; % [pu]

% Output of internal aging parameters
agingCalendric.capacityLossOfEOLDefinition  = 0.6;
agingCalendric.calendricLifetime            = 119/12*365*24*3600; % Calendric lifetime according to formula until 60% SOH

end
