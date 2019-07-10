%% plotResultsFcr
% 
%   Plotting script for fcr results
%   2017-01-04 Maik Naumann, Felix Kiefl
%%

function [  ] = plotFcrProfile( ees, varargin )

%% Get default figure settings
run('figureSettingsDefault.m')

%% Prepare input data
p       = inputParser; 
% expectedTimeUnit    = {'years', 'days', 'hours', 'minutes', 'seconds', ...
%                         'year', 'day', 'hour', 'minute', 'second'}; % limiting possible time units
% expectedYScale      = {'linear', 'log'};
defVal  = NaN; 
 
% addParameter(p, 'timeUnit', defVal, @(x) any(validatestring(x, expectedTimeUnit))); 
addParameter(p, 'figureNo', defVal);
% addParameter(p, 'scaleYAxis', defVal, @(x) any(validatestring(x, expectedYScale)));

parse(p, varargin{:}); 
% timeUnit    = p.Results.timeUnit; 
figureNo    = p.Results.figureNo; 
% scaleYAxis  = p.Results.scaleYAxis; 

%% Plot fcr simulation results
simTime  = 1:1:(ees.inputSim.simEnd-ees.inputSim.simStart);
gridFreq   = ees.inputFcrProfiles.fcrFrequency;

figure(figureNo)
hold on
plot(simTime, -ees.pStorage(2:end)/ees.inputFcr.fcrMax)
plot(simTime, ees.fcrData.fcrLoad/ees.inputFcr.fcrMax)
plot(simTime, ees.fcrData.idcLoad(simTime)/ees.inputFcr.fcrMax)
plot(simTime, ((ees.soc(2:end)-0.5)))
plot(simTime, gridFreq - 50)
% plot(simulationTime, EES.fcrData.fcrNet, simulationTime, EES.fcrData.fcr30, simulationTime, EES.fcrData.fcrLoad/EES.fcrMax, simulationTime, -EES.powerStorage/EES.fcrMax, simulationTime, ((EES.SOC - 0.5)), simulationTime, gridFrequency - 50)
% legend('FCR direct', 'FCR with 30s delay', 'FCR with all degrees of freedom', 'Overall load', '\Delta SOC (related to 50%)', '\Delta f_{net} (related to 50Hz)')
legend('Total storage load', 'FCR with all degrees of freedom', 'IDC transactions', '\Delta SOC (related to 50%)', '\Delta f_{net} (related to 50Hz)')
grid on 

if(ees.inputFcr.flagResidential)
    figure(figureNo + 1)
    hold on
    plot(simTime, ees.fcrData.fcrLoad/ees.inputFcr.fcrMax)
    plot(simTime, ees.inputProfiles.genPV/ees.inputFcr.fcrMax)
    plot(simTime, ees.inputProfiles.load/ees.inputFcr.fcrMax)
    plot(simTime, ees.fcrData.residential.storageLoad/ees.inputFcr.fcrMax)
    plot(simTime, ees.pGrid/ees.inputFcr.fcrMax)
    plot(simTime, ((ees.soc(2:end)-0.5)))
    legend('FCR load', 'PV generation', 'Load', 'Storage load', 'Grid load', 'SOC')
    grid on
end

% time = 1:1:EES.fcrData.indexIDC - 1;
% figure(3)
% plot(time, EES.fcrData.economics.idcCostTotal, time, EES.fcrData.economics.idcArbitrage,  time, EES.fcrData.economics.idcProfit, time, EES.fcrData.economics.fcrProfit, time, EES.fcrData.economics.totalProfit, time, EES.fcrData.economics.totalProfitCum)
% legend('Costs IDC total', 'IDC arbitrage', 'Profit IDC', 'Profit PRL', 'Profit total', 'Profit total cum')