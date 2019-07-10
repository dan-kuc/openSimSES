%% 1.2.1 +++ allocateStartSheet()
%
% allocateStartSheet allocates the input data read from
% inputParameteres.xlsx to the respective fields in input struct inputSim
%
% INPUT
%   rawInputData    Cell matrix containing data specified in Excel sheet
%
% OUTPUT
%   inputSim        Input struct containing simulation parameters
%   2019-07-05 Daniel Kucevic
%
%%
function [inputSim] = allocateStartSheet(rawInputData)

valuesFromSheet    = rawInputData(:,2); % Get value column of cell matrix
unitsFromSheet     = rawInputData(:,3); % Get units of simStart and tSample
unitsFromSheet(any(cellfun(@(x) any(isnan(x)),unitsFromSheet),2),:) = []; % remove NaN cells

% Get values within cells
scenario        = lower(valuesFromSheet{1});
simEnd          = valuesFromSheet{2};
simStart        = 0;
tSample         = valuesFromSheet{3};
flagPlot        = valuesFromSheet{4};
flagSave        = valuesFromSheet{5};
flagLogAging    = valuesFromSheet{6};
flagLogBattEc   = valuesFromSheet{7};

simEndUnit      = unitsFromSheet{1};
tSampleUnit     = unitsFromSheet{2};

% Convert simEnd to seconds
switch lower(simEndUnit)
    case 'seconds'
        % It's all good here.
    case 'minutes'
        simEnd      = simEnd * 60;
        simStart    = simStart * 60;
    case 'days'
        simEnd      = simEnd * 86400;
        simStart    = simStart * 86400;
    case 'years'
        simEnd      = simEnd * 86400 * 365;
        simStart    = simStart * 86400 * 365;
    otherwise
        warning('No time unit specified for simEnd');
end

% Convert tSample to seconds
switch lower(tSampleUnit)
    case 'minutes'
        tSample = tSample * 60;
    case 'seconds'
        % It's all good here.
    otherwise
        warning('No time unit specified for tSample.');
end

% Write variables to structs
inputSim.scenario       = scenario;
inputSim.simStart       = simStart;
inputSim.simEnd         = simEnd;
inputSim.tSample        = tSample;
inputSim.flagPlot       = flagPlot;
inputSim.flagSave       = flagSave;
inputSim.flagLogAging   = flagLogAging;
inputSim.flagLogBattEc  = flagLogBattEc;
end

