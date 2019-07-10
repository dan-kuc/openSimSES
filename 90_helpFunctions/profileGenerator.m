%% Create Load Profile with linear optimization

% Generate a LodeProfile with Input Data:
%   Arrive Time    [1xn]
%   Depature Time  [1xn]
%   Initial SOC    [1xn]
%   Maximum Power for each Bus [1x1]
%   Maximum combined Power     [1x1]
%   
% Output Data:
%   Load Profile [1x#TimeSteps]

%% Start function
function [LoadProfile] = profileGenerator(varargin)
% Input data
p       = inputParser;  % generate parsing handle
defVal  = NaN;          % set def value for parsing
% add parameter accepted for input
addParameter(p ,  't_period',      defVal  );
addParameter(p ,  'arriveTime',    defVal  );
addParameter(p ,  'depatureTime',  defVal  );
addParameter(p ,  'initialSOC',    defVal  );
addParameter(p ,  'P_LS_MAX',      defVal  );
addParameter(p ,  'batterySize',   defVal  );
addParameter(p ,  'P_BusMAX',      defVal  );
% parse input
parse(p, varargin{:})
% write parsed input into local var
t_period       = p.Results.t_period;  % sample Time [min]
arriveTime     = p.Results.arriveTime * (60/t_period); % arrive time at Station [Time step] (Time shift: 0 == 12h)
depatureTime   = p.Results.depatureTime * (60/t_period); % depaturetime at Station [Time Step]
initialSOC     = p.Results.initialSOC; % SOC at arrive time
P_LS_MAX       = p.Results.P_LS_MAX; % [kW] maximum power from grid and buffer storage
batterySize    = p.Results.batterySize; % [kWh]
P_BusMAX       = p.Results.P_BusMAX; % [kW]

%% Compute further input data

NC = 24*(60/t_period); % # time steps a day
NB = length(arriveTime); % # Busses

%% Battery and Charge computation

chargeMatrix = zeros(NC,NB); % equal 1 if Bus j is at time step i at the charging station
for i = 1:NC
    for j = 1:NB
        if (i >= arriveTime(j) && i < depatureTime(j))
            chargeMatrix(i,j) = 1;
        end
    end
end

E_init = initialSOC * batterySize; % battery energy content at arrive time

%% start optimization
P_LS2B	= optimvar('P_LS2B',NC,NB,'LowerBound',0, 'UpperBound',P_LS_MAX);
E       = optimvar('E',NC,NB,'LowerBound',0, 'UpperBound',batterySize);

for i = 1:NC
    linprob = optimproblem('ObjectiveSense', 'minimize','Objective', sum(P_LS2B(i,:)));
end

c1 = optimconstr(NC,1);
c2 = optimconstr(NC,NB);
c3 = optimconstr(NC,NB);

tic

for i = 1:NC % Time loop
    c1(i,1) = sum(P_LS2B(i,:)) <= P_LS_MAX; % maximum power of all busses combined
   for j = 1:NB % Bus loop
   
       c2(i,j) = P_LS2B(i,j) <= P_BusMAX; % maximum power for each bus
    
       if i == 1
           c3(i,j) = E(i,j) == E_init(j) + chargeMatrix(i,j) .* P_LS2B(i,j) *(t_period/60);
       elseif i >= depatureTime(j)
           c3(i,j) = batterySize == E(i-1,j) + chargeMatrix(i,j) .* P_LS2B(i,j) *(t_period/60);
       elseif i >= 2
           c3(i,j) = E(i,j) == E(i-1,j) + chargeMatrix(i,j) .* P_LS2B(i,j) *(t_period/60);
       end % if
   end % Bus
end % Time

linprob.Constraints.C01 = c1;
linprob.Constraints.C02 = c2;
linprob.Constraints.C03 = c3;

linsol = solve(linprob);

toc %end optimization

E = linsol.E;
P_LS2B = linsol.P_LS2B;
LP = P_LS2B';
Loadprofiledummy = sum(LP);

%% Plotting
clearvars	-except t_period batterySize E P_LS2B LoadProfile arriveTime depatureTime Loadprofiledummy;
fig1 = figure; 
plot(E./batterySize); ylim([0 1]); xlim([0 24*60/t_period]); xlabel('Time'); ylabel('SOC');
xticks(0:2*60/t_period:24*60/t_period); xticklabels([12:2:22,0:2:12]);
fig2 = figure; 
plot(P_LS2B); xlim([0 24*60/t_period]); xlabel('Time'); ylabel('Power / kW');
xticks(0:2*60/t_period:24*60/t_period); xticklabels([12:2:22,0:2:12]);
fig3 = figure;
area(Loadprofiledummy); xlim([0 24*60/t_period]); xlabel('Time'); ylabel('Power / kW');
xticks(0:2*60/t_period:24*60/t_period); xticklabels([12:2:22,0:2:12]);

% Combined figure SOC and Load Profile
fig4 = figure;
yyaxis left
h=area(Loadprofiledummy);
h(1).FaceColor = [0 0.5 0];
ylabel('Power[kW]')
yyaxis right
rgbMatrix = rand(length(arriveTime), 3);
j=plot(E./batterySize, 'color','b'); ylim([0 1]); xlim([0 24*60/t_period]); xlabel('Time'); ylabel('SOC');
for i= 1:length(arriveTime)
j(i).Color         = rgbMatrix(i,:);
j(i).LineWidth     = 1.5;
j(i).LineStyle     = '-';
j(i).Marker        = 'o';
j(i).MarkerIndices = [round(arriveTime(i)) round(depatureTime(i))];
end
xticks(0:2*60/t_period:24*60/t_period); xticklabels([12:2:22,0:2:12]);
%legend('Load','SOC1','SOC2','SOC3','Location','northwest');

%% write into output

Loadprofiledummy = Loadprofiledummy'; % shift Dimension
LoadProfile = [Loadprofiledummy(720:1440);Loadprofiledummy(1:719)]; % shift time base (00:00 == LoadProfile(1) and 12:00 == LoadProfile(720))
end

