
function plotDGisUnitProfiles(ees, varargin)

p = inputParser;

% default values in case parameter is not set
expectedTimeUnit    = {'years', 'days', 'hours', 'minutes', 'seconds', ...
                        'year', 'day', 'hour', 'minute', 'second'}; % limiting possible time units

defVal = nan;
timeUnit0 = 'days';

addParameter(p, 'axis', defVal); 
addParameter(p, 'timeUnit', timeUnit0, @(x) any(validatestring(x, expectedTimeUnit))); 

parse(p, varargin{:}); 

axis        = p.Results.axis; 
timeUnit    = p.Results.timeUnit;

if ~isgraphics(axis)
    figure;
    axis = gca;
end

switch timeUnit
    case {'day','days'}
        x2SEC = 24*3600;
end

profiles    = ees.inputProfiles;
genPV       = profiles.genPV(:);
genWind     = profiles.genWind(:);
load        = profiles.load(:);
netLoad     = load - (genPV + genWind);

pBatt       = ees.pStorage(:);
pDiesel     = ees.pDiesel(:);
% pDieselDisp = - pDiesel(:) + min(pBatt(:), 0);

inputSim    = ees.inputSim;
time        = linspace(inputSim.simStart, inputSim.simEnd/x2SEC, length(load));
time        = time(:);



hold(axis, 'on')
grid(axis, 'on')

h2(4) = fill(axis, [time; flipud(time)], [netLoad; 0*netLoad],'r');

h2(2) = fill(axis, [time; flipud(time)], [pDiesel; 0*pDiesel],'g');
h2(3) = fill(axis, [time; flipud(time)], min([-pBatt; 0*pBatt],0),'b');
% h2(5) = fill(axis, [time; flipud(time)], max([-pBatt; 0*pBatt],0)+[pDiesel;0*pDiesel],'b');
h2(5) = fill(axis, [time; flipud(time)], [max(-pBatt,0)+pDiesel; flipud(pDiesel)],'b');
h2(1) = plot(axis, time, netLoad);

% h2(1) = plot(axis, time, netLoad);

% h2(1).Color = 'k';
% h2(1).LineWidth = 1.5;

h2(2).FaceColor = [0.65 0.67 0];
% h2(2).FaceAlpha = 0.5;
h2(2).EdgeColor = 'none';

h2(3).FaceColor = [0 0.4 0.75];
% h2(3).FaceAlpha = 0.5;
h2(3).EdgeColor = 'none';
h2(5).FaceColor = [0 0.4 0.75];
% h2(3).FaceAlpha = 0.5;
h2(5).EdgeColor = 'none';

h2(4).FaceColor = 'r';
h2(4).EdgeColor = 'none';

h2(1).Color = 'k';
h2(1).LineWidth = 1.0;

legend(axis, [h2(3), h2(2), h2(4)], 'battery', 'diesel gen', 'load loss and curtailment', ...
        'Orientation', 'horizontal') %, 'Location','northoutside')
legend(axis, 'boxoff')

xlim(axis, [time(1) time(end)]);

end