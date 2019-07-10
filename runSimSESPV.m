clc
clearvars 
close all
run('addRequiredPaths'); 

try
    load('01_profileData\Household_Profile.mat')
catch
    error(['Please download profile Nr. 28 from the servers of HTW Berlin',... 
            'https://pvspeicher.htw-berlin.de/veroeffentlichungen/daten/',... 
            'and put it into the folder 01_profileData']);
end
    

for i=1:1

%% 1.0 +++ runSimSES.m 
%
%   +++ Description of SimSES goes here +++
%
%   Script to run SimSES with the excel input file 'inputParameters.xlsx',
%   where most of the inputs are set.
%   Input parameters can be categorized as simulation parameters
%   (inputSim), technical parameters (inputTech) and economic parameters
%   (inputEconomics). For special scenarios there are further input
%   structs, e.g. inputPcr for simulation of a primary control reserve
%   application.
%%

run('addRequiredPaths');
warning('off', 'MATLAB:dispatcher:UnresolvedFunctionHandle');

disp(['Profile: ',num2str(i)]);
%% Preparing MATLAB
% Global helping variables for conversion
global gvarYEARS2SECONDS gvarDAYS2SECONDS gvarKWH2WS
gvarYEARS2SECONDS   = 3600 * 24 * 365;  % helping variable to convert between years and seconds
gvarDAYS2SECONDS    = 3600 * 24;        % helping variable to convert between days and seconds
gvarKWH2WS          = 3600e3;           % helping variable to convert between kWh and Ws

%% Excel input data
% Get simulation parameters. This contains the chosen scenario which is
% needed to determine which functions should be called.
inputSim     = getGeneralInput('inputParametersPV.xlsx');

[inputTech, inputEconomics] = getTechnoEconomicInput('inputParametersPV', inputSim.scenario);


%% Input profiles

localFilesFolder = '01_profileData';

        % Residential PV Home

if ~exist('pvGenProfile','var')
    pvGenProfile    = returnInputProfile(   ...
        'profileFileName',      'PV_EEN_Power_Munich_2014.mat',                         ... % this could be set in excel as well
        'localFilesFolder',     localFilesFolder,                                       ...
        'verifyHashCode',       false                                                   );
end


loadProfile = double(loadprofile{1,i});

inputSim.tProfileLoad   = 1 * gvarYEARS2SECONDS;        % [s] length of input load profile
inputSim.tProfilePV     = 1 * gvarYEARS2SECONDS;        % [s] length of input generation profile


%% Simulation parameters

inputSim.plotFrom       = inputSim.simStart;            % [s] starting time of plot
inputSim.plotTo         = inputSim.simEnd;              % [s] last time to be included in plot
inputSim.plotTimeUnit   = 'days';                       % [-] depicts time unit for plotting (ticks of x-axis)

%% residential pv-battery system
run('createTechParamPVHomeStorage.m')

ees = residential('inputSim',	inputSim,       ...
    'inputTech',                inputTech,      ...
    'inputProfiles',            inputProfiles,  ...
    'inputForecast',            inputForecast   );


disp('Start Matlab Simulation')         % Display start of simulation at command window

tic
    ees = runStorage( ees );                % call run storage method for simulation run
toc

disp('Simulation complete. Evaluating...');
ees = evalTechnicalResidential( ees );  % calculate technical assessment values
                
% Plotting
if inputSim.flagPlot
    disp('Plotting.')

    % Get number of figures that are currently open
    h =  findobj('type','figure');
    openFigures = length(h);

    plotStorageData( ees,   'figureNo',     openFigures + 1,                        ...
        'timeFrame',    [ees.inputSim.plotFrom ees.inputSim.plotTo],    ...
        'timeUnit',     ees.inputSim.plotTimeUnit);

    % Plotting of aging results when logging values are available
    if(inputSim.flagLogAging && ~strcmp(inputTech.typeAgingMdl, 'no aging'))
        plotAging( ees, 'figureNo', openFigures + 3, 'timeUnit', ees.inputSim.plotTimeUnit, 'scaleYAxis', 'log');
    end           

end


%% Saving workspace variables.
% Save ees object.
if inputSim.flagSave
		% When specifying filepaths, use / instead of \ for
		% unix & macOS compability. Windows handles / just fine
		save(['03_simulationResults/EES_PV_profile_',num2str(i,'%02d'),'.mat'], 'ees');
		disp('Results saved.')
end

end