%%Run runSimSES.m with excel input file
%
%   Script to run SimSES with the excel input file 'inputParameters.xlsx',
%   where most of the inputs are set.
%   Input parameters can be categorized as simulation parameters
%   (inputSim), technical parameters (inputTech) and economic parameters
%   (inputEconomics). For special scenarios there are further input
%   structs, e.g. inputFcr for simulation of a primary control reserve
%   application.
%%
clc, clear
close all
run('addRequiredPaths'); 
warning('off', 'MATLAB:dispatcher:UnresolvedFunctionHandle');

%% Preparing MATLAB
% Global helping variables for conversion
global gvarYEARS2SECONDS gvarDAYS2SECONDS gvarKWH2WS
gvarYEARS2SECONDS   = 3600 * 24 * 365;  % variable to convert between years and seconds
gvarDAYS2SECONDS    = 3600 * 24;        % variable to convert between days and seconds
gvarKWH2WS          = 3600e3;           % variable to convert between kWh and Ws

%% Excel input data
% Get simulation parameters. This contains the chosen scenario which is
% needed to determine which functions should be called.
inputSim    = getGeneralInput('inputParametersPS.xlsx');
simScenario  = inputSim.scenario;
[inputTech, inputEconomics] = getTechnoEconomicInput('inputParametersPS', inputSim.scenario);

try
    load('01_profileData\Industry_Input_Profiles.mat')
catch
    error(['Please download the profiles from the servers of TU Munich',...
            'http:',...
            'and put it into the folder 01_profileData']);
end
    
load_profiles{1,1} = int16(IndustryProfiles.ip_for_ref_sp_cluster1*100); % values between 0 and 1
load_profiles{1,2} = int16(IndustryProfiles.ip_for_ref_sp_cluster2*100);
load_profiles{1,3} = int16(IndustryProfiles.ip_for_ref_sp_cluster3*100);

efficiency_sim = zeros(length(load_profiles),1);
PS_limit_sim = zeros(length(load_profiles),1);
PS.power_storage = zeros(length(load_profiles),(inputSim.simEnd-inputSim.simStart)/inputSim.tSample);


%             1    2   3
PS_limit_opt = ...
	   1e5*[0.66,0.83,0.80];   
   
for profile = 1:3

	inputTech.pPeakShaveThresh = PS_limit_opt(profile);
	inputTech.pPeakShaveThresh = ceil(inputTech.pPeakShaveThresh/1e3)*1e3;
	inputTech.loadProfile	= double(load_profiles{1,profile}); % [values between 0 and 100]; 

	inputSim.loadProfileLength  = gvarYEARS2SECONDS;        % [s] length of input load profile
    
    inputTech.pPeak = 1e5; % set to 100kW

	%% Simulation parameters
	inputSim.plotFrom       = inputSim.simStart;            % [s] starting time of plot
	inputSim.plotTo         = inputSim.simEnd;              % [s] last time to be included in plot
	inputSim.plotTimeUnit   = 'hours';                       % [-] depicts time unit for plotting (ticks of x-axis)

	run('createTechParamPeakShave.m')
		ees = peakshave( ...
			 'inputSim',         inputSim,       ...
			 'inputTech',        inputTech,      ...
			 'inputProfiles',    inputProfiles   );
	% Clear unnecessary workspace data
	clear loadProfile
	% Run simulation with generated object.
		disp('Start Matlab Simulation')         % Display start of simulation at command window 
		tic   
		ees = runPSStorage( ees );              % call run storage method for simulation run
		toc
		disp('Simulation complete'); 
	% Call evaluation functions for analysis of simulation.
		disp('Evaluating:')
		ees = evalTechnicalPeakShave( ees );  % calculate technical assessment values
    
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
		save(['03_simulationResults/EES_PS_profile_',num2str(profile,'%02d'),'.mat'], 'ees');
		disp('Results saved.')
	end
end
