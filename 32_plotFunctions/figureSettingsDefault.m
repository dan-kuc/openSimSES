%% Figure settings: Default
% General settings
set(0,'DefaultAxesFontName','Arial');
set(0,'DefaultTextFontName','Arial');
set(0,'defaulttextinterpreter','tex')
set(0,'defaultlinelinewidth',1.5)

% Set text style
fontsize = 12;
textstyle = {'Fontname','Arial','FontSize',fontsize};

% Set plot style
MarkerList = {'+'; 'o'; '*'; 'x'; 's'; 'd'; 'p'; 'h'; '^'};
plotstyles{1} = {'LineStyle','-', 'LineWidth',1.5, 'MarkerSize',8.0};
plotstyles{2} = {'LineStyle','--', 'LineWidth',1.5, 'MarkerSize',8.0};
plotstyles{3} = {'LineStyle',':','LineWidth',1.5, 'MarkerSize',8.0,'LineWidth',1.5};

% Color map for standard plots
colors = [  0.0000    0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840];
