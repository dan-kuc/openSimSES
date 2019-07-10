clc
clearvars 
close all

run('addRequiredPaths'); 

try
    load('01_profileData\Frequency_2014.mat')
catch
    error(['Please download the profiles from the servers of 50Hertz Transmission GmbH',... 
        'https://www.50hertz.com/de/Transparenz/Kennzahlen/Regelenergie/ArchivRegelenergie/ArchivNetzfrequenz',...
        'and put it into the folder 01_profileData']);
end

for i=1:1
disp(['Profile: ' num2str(i)]);
%% Run SimSES.m with excel input file
%
%   +++ Description of SimSES goes here +++
%
%   Script to run SimSES with the excel input file 'inputParameters.xlsx',
%   where most of the inputs are set.
%   Input parameters can be categorized as simulation parameters
%   (inputSim), technical parameters (inputTech) and economic parameters
%   (inputEconomics). For special scenarios there are further input
%   structs, e.g. inputFcr for simulation of a primary control reserve
%   application.

%%


run('addRequiredPaths'); 
warning('off', 'MATLAB:dispatcher:UnresolvedFunctionHandle');

%% Preparing MATLAB
% Global helping variables for conversion
global gvarYEARS2SECONDS gvarDAYS2SECONDS gvarKWH2WS
gvarYEARS2SECONDS   = 3600 * 24 * 365;  % helping variable to convert between years and seconds
gvarDAYS2SECONDS    = 3600 * 24;        % helping variable to convert between days and seconds
gvarKWH2WS          = 3600e3;           % helping variable to convert between kWh and Ws

%% Excel input data
% Get simulation parameters. This contains the chosen scenario which is
% needed to determine which functions should be called.
inputSim    = getGeneralInput('inputParametersFCR.xlsx');

[inputTech, inputEconomics, inputFcr] = getTechnoEconomicInput('inputParametersFCR', inputSim.scenario);


%% Input profiles

frequencyProfile = double(frequency);
frequencyProfile(isnan(frequencyProfile)) = 50.0;


%% Simulation parameters

inputSim.simStart       = 0;                            % [s] starting time of simulation
inputSim.plotFrom       = inputSim.simStart;            % [s] starting time of plot
inputSim.plotTo         = inputSim.simEnd;              % [s] last time to be included in plot
inputSim.plotTimeUnit   = 'days';                       % [-] depicts time unit for plotting (ticks of x-axis)

%% FCR

run('createTechParamFcrStorage.m')

% Create object
ees = fcr(   'inputSim',        inputSim,       ...
    'inputTech',       inputTech,      ...
    'inputProfiles',   inputProfiles,  ...
    'inputFcr',        inputFcr,       ...
    'inputFcrProfiles',inputFcrProfiles);

% Run simulation with generated object.
disp('Start Matlab Simulation')

tic
ees = runFcrStorage( ees );
toc

disp('Simulation complete. Evaluating...');

ees = evalTechnicalFcr(ees); % Technical evaluation

if inputSim.flagPlot
    disp('Plotting.')
    h =  findobj('type','figure');
    openFigures = length(h);

    plotStorageData( ees, 'figureNo', openFigures + 1,         ...
        'timeFrame',    [inputSim.plotFrom inputSim.plotTo],    ...
        'timeUnit',     inputSim.plotTimeUnit                   );

    % Plotting of aging results when logging values are available
    if(inputSim.flagLogAging && ~strcmp(inputTech.typeAgingMdl, 'no aging'))
        plotAging( ees, 'figureNo', openFigures + 2, 'timeUnit', ees.inputSim.plotTimeUnit, 'scaleYAxis', 'log');
    end

    % Plotting of FCR profiles results when logging values are available
    if(inputFcr.flagLogFcrResults)
        plotFcrProfile( ees, 'figureNo', openFigures + 3 );
    end         
end
     

%% Saving workspace variables.
% Save ees object.
if inputSim.flagSave
    % When specifying filepaths, use / instead of \ for
    % unix & macOS compability. Windows handles / just fine
    save(['03_simulationResults/EES_FCR_profile_',num2str(i,'%02d'),'.mat'], 'ees');
    disp('Results saved.')
end


end