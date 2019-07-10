function [hFig] = plotDGis(ees, varargin)

if nargin < 2
    scrsz       = get( groot, 'Screensize' );
    hFig        = figure('Position',[80 30 scrsz(3)*3/4 scrsz(4)*0.9]);
else
    hFig = varargin{2};
end

D2SEC       = 24 * 3600;

profiles    = ees.inputProfiles;
genPV       = profiles.genPV(:);
genWind     = profiles.genWind(:);
load        = profiles.load(:);
netLoad     = load - (genPV + genWind);

pBatt       = ees.pStorage(:);
pDiesel     = ees.pDiesel(:);
% pDieselDisp = - pDiesel(:) + min(pBatt(:), 0);

inputSim    = ees.inputSim;
time        = linspace(inputSim.simStart, inputSim.simEnd/D2SEC, length(load));
time        = time(:);

% plot load
hAx1 = subplot(3,1,1);
hold(hAx1, 'on')
grid(hAx1, 'on')

h1(1) = area(hAx1, time, load);
h1(2) = area(hAx1, time, -genPV-genWind);
h1(3) = area(hAx1, time, -genWind);
h1(4) = plot(hAx1, time, netLoad);

h1(1).FaceColor = [0.4 0.4 0.4];
h1(1).EdgeColor = 'none';
h1(1).FaceAlpha = 0.7;

h1(2).FaceColor = [1 0.9 0];
h1(2).EdgeColor = 'none';
h1(2).FaceAlpha = 0.7;

h1(3).FaceColor = [1 0.6 0];
h1(3).EdgeColor = 'none';
h1(3).FaceAlpha = 0.7;

h1(4).Color = 'k';
h1(4).LineWidth = 1.5;

legend(hAx1, [h1(4), h1(1), h1(3), h1(2)], 'net load', 'load', 'wind', 'PV', ...
        'Orientation', 'horizontal') %, 'Location','northoutside')
legend(hAx1, 'boxoff')



hAx2 = subplot(3,1,2);

plotDGisUnitProfiles(ees, 'axis', hAx2)



hAx3 = subplot(3,1,3);



hold(hAx3, 'on')
grid(hAx3, 'on')

h3 = plot(hAx3, time,ees.soc);

h3.Color = 'k';
h3.LineWidth = 1.5;


ylabel(hAx1, 'Load and generation')
ylabel(hAx2, 'BESS and Diesel Generator')
ylabel(hAx3, 'BESS SOC')
xlabel(hAx3, 'Days')

linkaxes([hAx1,hAx2], 'y')
linkaxes([hAx1,hAx2,hAx3], 'x')
xlim([0,time(end)])


end

