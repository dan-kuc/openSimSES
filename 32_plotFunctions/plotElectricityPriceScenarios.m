clc, clear all
%% Figure settings
% Set plot style
set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultTextFontName','Times New Roman');
set(0,'defaulttextinterpreter','tex')
set(0,'defaultlinelinewidth',1.5)

fontsize = 12;
textstyle = {'Fontname','Times New Roman','FontSize',fontsize}; % 'FontWeight','demi',
MarkerList = {'+'; 'o'; '*'; 'x'; 's'; 'd'; 'p'; 'h'; '^'}; % hier koennen auch noch weitere Marker eingesetzt werden
plotstyles{1} = {'LineStyle','-', 'LineWidth',1.5, 'MarkerSize',8.0};
plotstyles{2} = {'LineStyle','--', 'LineWidth',1.5, 'MarkerSize',8.0};
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
% colors = colormap(jet); % parula hsv jet

figureFolder = '07_Results\PV_Hess\Figures\';
pdfFolder = [figureFolder, 'Pdf\'];

addpath(genpath('07_Results\PV_Hess\'))
% load('ees_xs_365days.mat');
% load('ees_1a_SampleTime_60_7200s.mat');

%Figure name
figure_name = 'ElectricityPriceScenarios';
file_name = 'ElectricityPriceScenarios';

%% Get price data
inputEconomics = econParamStdPVHomeStorage();
inputEconomics.general.depreciationPeriod = 10+21;
inputEconomics.general.yearStart = 2004;
% create application specific economic parameters 
% energyPricesConstant    = inputEconomics.pvHome.electricityPrice;

inputEconomics.pvHome.scenarioElectricityPrices = 'constant';
inputEconomics = createElectricityPrices( inputEconomics );
energyPricesConstant    = inputEconomics.pvHome.electricityPrice;

inputEconomics.pvHome.scenarioElectricityPrices = 'extrapolmeangrowthinflationadjusted';
inputEconomics = createElectricityPrices( inputEconomics );
energyPricesExtrapolmeangrowthIA      = inputEconomics.pvHome.electricityPrice;

energyPricesExtrapolmeangrowthIARate = 100*1/1e3*round(1e3*(-1+energyPricesExtrapolmeangrowthIA(end)/energyPricesExtrapolmeangrowthIA(end-1)));

inputEconomics.pvHome.scenarioElectricityPrices = 'extrapolmeangrowth';
inputEconomics = createElectricityPrices( inputEconomics );
energyPricesExtrapolmeangrowth   = inputEconomics.pvHome.electricityPrice;

energyPricesExtrapolmeangrowthRate = 100*1/1e3*round(1e3*(-1+energyPricesExtrapolmeangrowth(end)/energyPricesExtrapolmeangrowth(end-1)));

yearsExtrapolation      = 2004:2034;
        
f(1) = figure
hold on, box on, grid on

% plot(yearsExtrapolation, energyPricesExtrapolated, 'o', plotstyles{1}{:})
index_history = find(yearsExtrapolation <= 2017);
index_extrapolation = find(yearsExtrapolation >= 2017);

p(1) = plot(yearsExtrapolation(index_history), energyPricesConstant(index_history), 'k+', 'LineWidth', 1.0);
p(2) = plot(yearsExtrapolation(index_extrapolation), energyPricesConstant(index_extrapolation), plotstyles{2}{:}, 'Color', colors(2,:));
p(3) = plot(yearsExtrapolation(index_extrapolation), energyPricesExtrapolmeangrowthIA(index_extrapolation), plotstyles{2}{:}, 'Color', colors(1,:));
p(4) = plot(yearsExtrapolation(index_extrapolation), energyPricesExtrapolmeangrowth(index_extrapolation), plotstyles{2}{:}, 'Color', colors(3,:));

l1 = line([2017 2017], [0 0.7], 'LineStyle', ':', 'Color', [0 0 0], 'LineWidth',1.0);

legendEntriesComplete{1} = 'Historical electricity price';
legendEntriesComplete{2} = 'Increase with inflation rate: 2.0%';
legendEntriesComplete{3} = ['Increase by extrapolation (inflation-adjusted): ',...
         num2str(energyPricesExtrapolmeangrowthIARate),'%'];
legendEntriesComplete{4} = ['Increase by extrapolation: ',...
         num2str(energyPricesExtrapolmeangrowthRate),'%'];

l = legend(p([1,4,3,2]),legendEntriesComplete([1,4,3,2]), 'Location', 'NorthWest');
set(l, textstyle{:},'FontSize',fontsize)

% text(2014 - 1.25, 0.1, 'Average electricity price for 4 person households', textstyle{:});
% text(2014 - 0.75, 01, '$\leftarrow$', textstyle{:}, 'interpreter', 'latex');

xlabel('Year', textstyle{:})
ylabel('Electricity price Euro / kWh', textstyle{:})

% titleName = 'Return on investment depending on year of investment';
% title({titleName}, textstyle{:}, 'interpreter', 'none')

xlim([2004, 2034]);
ylim([0.15 0.60]);

xticks([2004:4:2012,2017,2022:4:2034])
yticks([0.15:0.05:0.60])

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

save(['07_Results\PV_Hess\Results\', file_name,'.mat'],'energyPricesConstant','energyPricesExtrapolmeangrowthIA','energyPricesExtrapolmeangrowth');
savefig([figureFolder, figure_name,'.fig']);
cleanfigure
saveTightFigure(f,[figureFolder,'Pdf\', figure_name,'.pdf'])