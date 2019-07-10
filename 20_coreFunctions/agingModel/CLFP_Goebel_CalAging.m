%% CLFP_Goebel_CalAging: Literature Calendric aging model (A123 cell)
% Model to compute the calendric aging of specified battery cell.
%
% Script to define function for an aging model 
% Cell type:    A123 ANR26650 - Literature values
% Aging model:  Cal aging model fitted to literature values
% Model type:   Literature: M. Swierczynski, D.-I. Stroe, A.-I. Stan, R. Teodorescu, and S. Kaer,
%               “Lifetime Estimation of the Nanophosphate LiFePO4/C Battery Chemistry
%               Used in Fully Electric Vehicles,” IEEE Trans. on Industry Applications,
%               vol. 51, pp. 3453–3461, July 2015.
% Model source: Göbel, Hesse, Schimpe, Jossen, Jacobsen : IEEE Publication (submitted)
% Stress values:
%   temperature % [K] Cell temperature 
%   avgSOC      % [0-1] Average SOC between time1 and time2
%   time1       % [s] Start point of time of aging 
%   time2       % [s] End point of time of aging
%
% Output values: AgingCalendric
%   agingCalendric.relCapacityChange    % [pu]
%   agingCalendric.relResistanceChange  % [pu]
%
% To be handed over to storage object as function handle. Model computes
% the aging of the battery based on the input (stress factors) for given
% time steps.
%
% 2016-02-05 Holger Hesse
% 2017-08-07 Nam Truong: functionality needs to be checked
%%
function agingCalendric = CLFP_Goebel_CalAging(agingStress, ~, index, sampleTime, ~, ~)

%% Input assignment
temperature     = mean(agingStress.temperature(index));
avgSOC          = mean(agingStress.meanSOC(index));
time1           = agingStress.cumAgingTime;
time2           = agingStress.cumAgingTime + sampleTime;

%% Calculate calendric aging
% Beta parameters from the publication
b1 = 0.019;
b2 = 0.823;
b3 = 0.5195;
b4 = 3.258e-9;
b5 = 5.087;
b6 = 0.295;
b7 = 0.8;

T           = temperature - 273.15;             % Conversion of temperature unit from Kelvin to degrees Celsius
SOC         = avgSOC * 100;                     % Conversion of state of charge from [pu] to [%]
sec2month 	= 1 / (60 * 60 * 24 * 30.5);        % 60s*60min*24h*30.5d
t1          = time1 * sec2month;                % Conversion of time in months
t2          = time2 * sec2month;                % Conversion of time in months

% Calculate capacity fade
agingCalendric.relCapacityChange = -(((b1 * SOC^b2 + b3) * (b4 * T^b5 + b6) * t2^b7 - ...
                                    ((b1 * SOC^b2 + b3) * (b4 * T^b5 + b6) * t1^b7)) / 100); % [pu]

% Calculate resistance increase
% Resistance change is not reflected in this model
agingCalendric.relResistanceChange  = 0; % [pu]

% Output of internal aging parameters
agingCalendric.capacityLossOfEOLDefinition  = 0.8;
agingCalendric.calendricLifetime            = 166/sec2month; % Calendric lifetime according to formula with 25°C and 50% SOC until 80% SOH

end
