%% Analysis of PV-HESS Sizing

clc, clear all
%% Figure settings
% Set plot style
set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultTextFontName','Times New Roman');
set(0,'defaulttextinterpreter','tex')
set(0,'defaultlinelinewidth',1.5)

fontsize = 12;
textstyle = {'Fontname','Times New Roman','FontSize',fontsize}; % 'FontWeight','demi',
textstyle2 = {'Fontname','Times New Roman','FontSize',10}; % 'FontWeight','demi',
MarkerList = {'+'; 'o'; '*'; 'x'; 's'; 'd'; 'p'; 'h'; '^'}; % hier koennen auch noch weitere Marker eingesetzt werden
plotstyles{1} = {'LineStyle','-', 'LineWidth',1.5, 'MarkerSize',8.0};
plotstyles{2} = {'LineStyle','None', 'LineWidth',1.5, 'MarkerSize',8.0};
% plotstyles{1} = {'LineStyle','-', 'LineWidth',1.5}; % {'MarkerSize',6.0,'LineWidth',1.5};
% plotstyles{2} = {'LineStyle','-', 'LineWidth',1.0}; % {'MarkerSize',6.0,'LineWidth',1.5};
% plotstyles{3} = {'LineStyle','--','LineWidth',1.0}; % {'MarkerSize',6.0,'LineWidth',1.5};
% plotstyles{4} = {'LineStyle',':','LineWidth',1.5}; % {'MarkerSize',6.0,'LineWidth',1.5};
colors = [  0.0000    0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840];

%% Define folders and get data
addpath(genpath('07_Results\PV_Hess\'))
figureFolder = '07_Results\PV_Hess\Figures\';
pdfFolder = [figureFolder, 'Pdf\'];  
        
% load('PV_Hess_20a8P_PV1_10_WR0.25_1_BS1_10.mat')
load('PV_HESS_20a8P_PV1_10_WR0.1_0.3_BS1_10.mat')

global gvarYEARS2SECONDS gvarDAYS2SECONDS gvarKWH2WS
gvarYEARS2SECONDS   = 3600 * 24 * 365;  % helping variable to convert between years and seconds
gvarDAYS2SECONDS    = 3600 * 24;        % helping variable to convert between days and seconds
gvarKWH2WS          = 3600e3;           % helping variable to convert between kWh and Ws

% loadProfileNum              = 1:8;
% PVPeakPower                 = [1:1:10]*1000;
% batteryNominalEnergy        = [1:1:10] * gvarKWH2WS;
% powerElectronicsRatedPower 	= [0.25 0.5 0.75 1]; % * batteryNominalEnergy / 3600;

evaluationNumber_Name = 'avgEtaSystem'; % avgEtaSystem SOHCapacityNow selfConsumRate selfDependRate curtailedEnergy

loadProfileNum              = 1:8;
PVPeakPower                 = results_total.PVPeakPower(:,1,1)';
powerElectronicsRatedPower 	= results_total.powerElectronicsRatedPower(1,:,1); %PVPeakPower;
batteryNominalEnergy        = squeeze(results_total.batteryNominalEnergy(1,1,:))';

resultsTotalMean.PVPeakPower                = results_total.PVPeakPower;
resultsTotalMean.powerElectronicsRatedPower = results_total.powerElectronicsRatedPower;
resultsTotalMean.batteryNominalEnergy       = results_total.batteryNominalEnergy;

%% Get best configuration
for idx_PVPeakPower = 1:length(PVPeakPower)

for idx_batteryNominalEnergy = 1:numel(batteryNominalEnergy)

for idx_powerElectronicsRatedPower = 1:length(powerElectronicsRatedPower)

for idx_loadProfileNum      = 1:length(loadProfileNum)
 
    %% Get mean values
    for idx_loadProfile = 1:length(loadProfileNum)
        loadFields = fieldnames(results_total.resultsTechnical);
        for k = 1:numel(loadFields)
            resultsTechnical.(loadFields{k}) = mean(results_total.resultsTechnical(idx_PVPeakPower,idx_powerElectronicsRatedPower,idx_batteryNominalEnergy).(loadFields{k}));
        end  
        loadFields = fieldnames(results_total.resultsEconomics);
        for k = 1:numel(loadFields)
            resultsEconomics.(loadFields{k}) = mean(results_total.resultsEconomics(idx_PVPeakPower,idx_powerElectronicsRatedPower,idx_batteryNominalEnergy).(loadFields{k}));
        end 
    end
    resultsTotalMean.resultsEconomics(idx_PVPeakPower,idx_powerElectronicsRatedPower,idx_batteryNominalEnergy) = resultsEconomics;
    resultsTotalMean.resultsTechnical(idx_PVPeakPower,idx_powerElectronicsRatedPower,idx_batteryNominalEnergy) = resultsTechnical;

end
    evaluationNumber(idx_PVPeakPower,idx_powerElectronicsRatedPower,idx_batteryNominalEnergy) = eval(['resultsTechnical.', evaluationNumber_Name]);
%     evaluationNumber(idx_PVPeakPower,idx_powerElectronicsRatedPower,idx_batteryNominalEnergy) = (resultsTechnical.inStoredEnergy + resultsTechnical.outStoredEnergy) / 2 ./ results_total.batteryNominalEnergy(idx_PVPeakPower,idx_powerElectronicsRatedPower,idx_batteryNominalEnergy);
    profitIdx(idx_PVPeakPower,idx_powerElectronicsRatedPower,idx_batteryNominalEnergy) = resultsEconomics.profitIdx;

end
end
end

for idx_powerElectronicsRatedPower = 1:length(powerElectronicsRatedPower)

loadProfileNum              = 1:8;
PVPeakPower                 = results_total.PVPeakPower(:,1,1)';
powerElectronicsRatedPower 	= results_total.powerElectronicsRatedPower(1,:,1); %PVPeakPower;
batteryNominalEnergy        = squeeze(results_total.batteryNominalEnergy(1,1,:))';   
    
profitIdx_vec = [resultsTotalMean.resultsEconomics(:,idx_powerElectronicsRatedPower,:).profitIdx];
evaluationNumber_vec  = eval(['[resultsTotalMean.resultsTechnical(:,idx_powerElectronicsRatedPower,:).',evaluationNumber_Name,']']);

PVPeakPower = reshape(resultsTotalMean.PVPeakPower(:,idx_powerElectronicsRatedPower,:),[1,numel(resultsTotalMean.PVPeakPower(:,idx_powerElectronicsRatedPower,:))]);
powerElectronicsRatedPower = reshape(resultsTotalMean.powerElectronicsRatedPower(:,idx_powerElectronicsRatedPower,:),[1,numel(resultsTotalMean.powerElectronicsRatedPower(:,idx_powerElectronicsRatedPower,:))]);
batteryNominalEnergy = reshape(resultsTotalMean.batteryNominalEnergy(:,idx_powerElectronicsRatedPower,:),[1,numel(resultsTotalMean.batteryNominalEnergy(:,idx_powerElectronicsRatedPower,:))]);

[value_max_profitIdx(idx_powerElectronicsRatedPower) value_idx_profitIdx(idx_powerElectronicsRatedPower)] = max(profitIdx_vec);
[value_max_evaluationNumber(idx_powerElectronicsRatedPower) value_idx_evaluationNumber(idx_powerElectronicsRatedPower)] = max(evaluationNumber_vec);

PVPeakPower_max(idx_powerElectronicsRatedPower) = PVPeakPower(value_idx_profitIdx(idx_powerElectronicsRatedPower));
powerElectronicsRatedPower_max(idx_powerElectronicsRatedPower) = powerElectronicsRatedPower(value_idx_profitIdx(idx_powerElectronicsRatedPower));
batteryNominalEnergy_max(idx_powerElectronicsRatedPower) = batteryNominalEnergy(value_idx_profitIdx(idx_powerElectronicsRatedPower))/3600;

end

[value_max_end value_idx_end] = max(value_max_profitIdx);
% [value_max_end value_idx_end] = max(value_max_evaluationNumber);

PVPeakPower                 = results_total.PVPeakPower(:,1,1)';
powerElectronicsRatedPower 	= results_total.powerElectronicsRatedPower(1,:,1); %PVPeakPower;
batteryNominalEnergy        = squeeze(results_total.batteryNominalEnergy(1,1,:))';      
profitIdx                   = squeeze(profitIdx(:,value_idx_end,:));
evaluationNumber            = squeeze(evaluationNumber(:,value_idx_end,:));

% tbl = table(profitIdx(:,value_idx_end,:),PVPeakPower,batteryNominalEnergy/3600);

%Figure name
figure_name = ['PV_HESS_',evaluationNumber_Name];
file_name = ['PV_HESS_',evaluationNumber_Name];

%% Create figure
f(1) = figure
hold on, box on, grid on

colormap(parula)
[C,h] = contourf(PVPeakPower/1e3, batteryNominalEnergy/3600/1e3, evaluationNumber * 100);
% colorbar
clabel(C,h,textstyle2{:})

% Mark 
p(1) = plot(batteryNominalEnergy_max(value_idx_end) / 1e3, PVPeakPower_max(value_idx_end) / 1e3, 'x', 'Color',colors(4,:));
% https://undocumentedmatlab.com/blog/customizing-contour-plots

% yticks([0:1000:10000])

% Label axes
xlabel('Battery nominal energy / kWh', textstyle{:},'FontSize',fontsize);
ylabel('PV peak power / W', textstyle{:},'FontSize',fontsize); 
% title('Self dependancy rate / %', textstyle{:},'FontSize',fontsize);
% title('Self consumption rate / %', textstyle{:},'FontSize',fontsize);
% title('SOH capacity after 20 years / %', textstyle{:},'FontSize',fontsize);
% title('Curtailed PV energy / %', textstyle{:},'FontSize',fontsize);
% title('FEC', textstyle{:},'FontSize',fontsize);
title('Average system effiency', textstyle{:},'FontSize',fontsize);

% Legend
% l = legend(p(:),legendVector(:));
% set(l, textstyle{:},'FontSize',fontsize,'Location','NorthEast','Orientation','Vertical');
text((batteryNominalEnergy_max(value_idx_end) + 200)/1e3, (PVPeakPower_max(value_idx_end) - 100)/1e3,'max(PI)','LineStyle','none', textstyle{:},'FontSize',fontsize,'Color',colors(4,:));
% text((batteryNominalEnergy_max(value_idx_end) + 200)/1e3, (PVPeakPower_max(value_idx_end) - 2300)/1e3,'Opt. PV peak power','LineStyle','none', textstyle{:},'FontSize',fontsize,'Color',colors(4,:));
% text((batteryNominalEnergy_max(value_idx_end) - 700)/1e3, (PVPeakPower_max(value_idx_end) - 6000)/1e3,'Break-even','LineStyle','none', textstyle{:},'FontSize',fontsize,'Color',[0 0 0]);

ax.XLabel.FontSize = fontsize;
% ax.XLabel.FontWeight = 'bold';

ax.YLabel.FontSize = fontsize;
% ax.YLabel.FontWeight = 'bold';

% set(ax,'FontSize',12);
% set(ax,'GridLineStyle','-');
% set(ax,'GridColor',[178 178 178]/255);
% set(ax, 'GridAlpha', 1.0);
% set(ax,'LineWidth',2.0);

% legend('Location','East');
set(gcf, 'Units', 'centimeters');
set(gcf, 'Position', [10, 10, 15, 9]);

set(gca,'LooseInset',get(gca,'TightInset'))
set(gca,textstyle{:})

save(['07_Results\PV_Hess\Results\', file_name,'.mat']);
savefig([figureFolder, figure_name,'.fig']);
cleanfigure
saveTightFigure(f,[figureFolder,'Pdf\', figure_name,'.pdf'])