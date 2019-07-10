function [ ] = plotHeatMap( ees, axis, numberOfDaysSimulated, stepVector, varargin )
%plotHeatMap plots Heat Maps of different properties and is the SO-adapted
%version of plotHeatMap. It is called by plotStorageDataSO()
%
% INPUTS: EES, axis, numberOfDaysSimulated, plotValue
% OUTPUTS: none
% LAST UPDATED: 15.01.2018
% OWNER: Markus Förstl
%   

%% Get default figure settings
run('figureSettingsDefault.m')

global gvarDAYS2SECONDS

p = inputParser;

defVal = NaN; 
expectedPlotValue = {'soc', 'pBatt', 'pGrid'};

addParameter(p, 'plotValue', defVal, @(x) any(validatestring(x,expectedPlotValue))); 
parse(p,varargin{:}); 

if ees.inputSim.simStart == 0
    simStart = 1; 
else 
    simStart = ees.inputSim.simStart; 
end

tSample = ees.inputSim.tSample; 

plotValue = p.Results.plotValue;

plotProfile = ees.(plotValue)(stepVector); 

if strcmp(plotValue, 'pGrid')
    plotProfile = -1 * plotProfile; % Power fed into grid is positive
end

if strcmp(plotValue, 'soc')
    plotProfile = 100 * plotProfile; % Power fed into grid is positive
    plotTitle = 'SOC / %';
end

if strcmp(plotValue, 'pBatt')
    plotProfile = plotProfile / (ees.inputTech.eBattNom/3600); % Power fed into grid is positive
    plotTitle = 'Battery C-rate / h^{-1}';
    maxCRate  = 1/10*ceil(10*max(abs(plotProfile)));
end

%If the length of plotProfile is not dividable by the number of days simulated, it cannot be
%plotted as a heat map (reshape throws an error).
%Then it will be resampled accordingly.

if mod(length(plotProfile), numberOfDaysSimulated)
    scaleFactor = round(length(plotProfile)/numberOfDaysSimulated); 
    plotProfileResampled = resample(plotProfile, scaleFactor * numberOfDaysSimulated, length(plotProfile)); 
    plotMatrix = reshape(plotProfileResampled, [], numberOfDaysSimulated); 
else 
    plotMatrix = reshape(plotProfile, [], numberOfDaysSimulated); 
end
    
entriesPerDay = size(plotMatrix,1); 

axes(axis); 

imagesc(axis, plotMatrix); 
colormap(axis, 'jet'); 
colorbar(axis); 

if numberOfDaysSimulated ~= 1
    xlabel('Days', textstyle{:});
end

ylabel('Hour', textstyle{:});
yTicks = [1 round(entriesPerDay/8) round(entriesPerDay/4) ... %0 3 6 Uhr
    round(entriesPerDay/8*3) round(entriesPerDay/2) round(entriesPerDay/8*5) ... % 9 12 15 Uhr
    round(entriesPerDay / 4 * 3) round(entriesPerDay/8*7) entriesPerDay ]; % 18 21 24 Uhr
yTickLabel = {'0', '3', '6', '9' , '12', '15' , '18', '21', '24'};
set(axis, 'TickLength', [0 0], 'YTick', yTicks, 'YTickLabel', yTickLabel);

if strcmp(plotValue, 'soc')
    axis.CLim = [0 100];
else
    axis.CLim = [-maxCRate maxCRate];
end

title(axis, plotTitle, textstyle{:})

end

