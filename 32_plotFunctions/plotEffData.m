%% Plot efficiency function
%  summoned: example_Simulate_Residential-->plotEffData
%  summons: --
%  Modified by: Anupam Parlikar
%  on: 11-12-2018
%  version 2


function [loss_trend,xy] = plotEffData(ees,loss_trend,xy)
% Get values from object and calculate things to be plotted
eInStor             = ees.resultsTech.eInStor; 
% Todo: division by eInStor is only valid when the initial SOC of the
% battery is zero, or same as that at the end of simulation. ###### <---- ATTENTION ---- 
% Perhaps classify into charging losses and discharging losses. %Todo ??
% eInStor             = ees.resultsTechnicalFcr.eInStor;  % For FCR due to the structure of the ees object 
tSample             = ees.inputSim.tSample;
eLossSelfDis        = ees.eLossSelfDis;

eLossSelfDisRelative        = 100 * eLossSelfDis / eInStor; 
eLossInverter               = sum(ees.pLossInv) * tSample; 
eLossInverterRelative       = 100 * eLossInverter / eInStor;

if(isempty(ees.cellStates)==0)
 
    eLossBatt           = sum(ees.cellStates.powerLoss)*tSample; %TODO is this the correct way then? Battery internal losses
    eLossBattResidual   = eLossBatt; % Battery internal losses renamed just to fit general structure of program
    eLossBattResidualRelative   = 100 * eLossBattResidual / eInStor; 
    etaSystem           = 100 - (eLossSelfDisRelative+eLossInverterRelative+eLossBattResidualRelative);
    lossSystem  = 100 - etaSystem; 
else
    etaSystem   = ees.resultsTech.avgEtaSystem * 100; % we want to display eta in percent
    lossSystem  = 100 - etaSystem;  
    eLossBattTotal      = ees.resultsTech.eLossBatt; 
    eLossBattResidual   = eLossBattTotal - eLossSelfDis;
    eLossBattResidualRelative   = 100 * eLossBattResidual / eInStor; 
end

loss_trend(xy,1:3)=[eLossInverterRelative eLossBattResidualRelative eLossSelfDisRelative];
xy=xy+1;


%% Bar graph
figure('Name','Efficiency and losses');
y = [etaSystem lossSystem 0 0 0; 0 0 eLossInverterRelative eLossSelfDisRelative eLossBattResidualRelative]; 
bar(y,'stacked');
labels = [{'Round-trip efficiency'}, {'Losses'}];
xticklabels(labels);
ylabel('Percentage of input energy (%)');
legend('System efficiency','System losses','Power electronics losses', 'Self-discharge losses', 'Battery losses');

%% Sankey Diagram
label_sankey = [{'Charging Energy'}, {'Power Electronics'}, {'Battery'}, {'Self-discharge'}, {'Energy Discharged'}];  
sep = [1 10];
drawSankey(100, [eLossInverterRelative eLossBattResidualRelative eLossSelfDisRelative], '%', label_sankey, sep); % function drawSankey for plotting of Sankey Diagram by James Spelling
end

