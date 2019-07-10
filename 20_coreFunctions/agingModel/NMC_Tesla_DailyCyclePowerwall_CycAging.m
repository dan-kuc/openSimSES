%% NMC_Tesla_DailyCyclePowerwall_CycAging: Cyclic aging model
% 
% Script to define function for an aging model 
% Cell type:    Tesla Powerwall NMC / Panasonic NCA
% Aging model:  Tesla Daily Cycle Powerwall
% Model type:   Datasheet fit
% Model source: Powerwall manufacturers warranty certificate (Germany): 1073253-00-A, 22.01.2016
% Input values: Stress values
%   temperature                 % [K] Cell temperature 
%   avgCRate                    % [1/h] Average C-Rate of cycle
%   minSOC                      % [0-1] min SOC of cycle
%   maxSOC                      % [0-1] max SOC of cycle
%   cumRelCapacityThroughput    % [pu] Cumulated relative capacity throughput until end of cycle since begin of life
%   relCapacityThroughput       % [pu] Relative capacity throughput until end of cycle since begin of last cycle
%
% Output values: AgingCyclic
%   agingCyclic.relCapacityChange    % [pu]
%   agingCyclic.relResistanceChange  % [pu]
%
% Function owner: Maik Naumann
% Creation date: 02.03.2016
%
%%
function agingCyclic = NMC_Tesla_DailyCyclePowerwall_CycAging(agingStress, ~, idxCalendarAging, idxCycleAging, ~, ~)

%% Input assignment
cumRelCapacityThroughput    = agingStress.cumRelCapacityThroughput;
minSOC                      = agingStress.minSOC(idxCycleAging);
maxSOC                      = agingStress.maxSOC(idxCycleAging);

% Determine current DOC
DOC = abs(maxSOC - minSOC);

%% Calculate cyclic aging

% Calculation calendric capacity change with exponential function fitted on data of warranty sheet with 6.4 kWh storage size:
% Relative energy throughput | SOH / 0-1: [0 1.00; 1250 0.85; 2812.5; 5625 0.6]
% Valid for 25°C ambient and battery temperature for SOH-estimation with 2 kW discharge

% General model Exp2:
%      f(x) = a*exp(b*x) + c*exp(d*x)

% Set up fittype and options.
% ft = fittype( 'exp2' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [0.375894482780836 3.8586992420628e-05 -0.375894482780835 -0.000306559905059778];
% 
% Goodness of fit:
%   SSE: 2.409e-08
%   R-square: 1
%   Adjusted R-square: NaN
%   RMSE: NaN

% Coefficients:
a =       12.36;
b =  -0.0001138;
c =      -12.36;
d =  -0.0001251;

cumRelChargeThroughput1 = cumRelCapacityThroughput - DOC;
cumRelChargeThroughput2 = cumRelCapacityThroughput;

% Calculate relative capacity change
agingCyclic.relCapacityChange    = -(a*exp(b*cumRelChargeThroughput2) + c*exp(d*cumRelChargeThroughput2) - ...
                                    (a*exp(b*cumRelChargeThroughput1) + c*exp(d*cumRelChargeThroughput1))); % [pu]

% Calculate relative resistance change
% Resistance change is not reflected in this model
agingCyclic.relResistanceChange  = 0; % [pu]

% Output of internal aging parameters
agingCyclic.capacityLossOfEOLDefinition  = 0.6;
agingCyclic.calendricLifetime            = 2785; % Cycle lifetime according to formula until 60% SOH
agingCyclic.cycleLifetime                = 2785; % Cycle lifetime according to formula until 60% SOH

end

