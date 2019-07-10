%% characterizeStress
%
%   Calls the stress characterization method defined by the stress 
%   characterization configuration
%
%   Input/Output: EES object
%
%   This functions calls the stress characterization method, which is defined
%   within the stressCharacterization object. Dependent on the current
%   simulation step, the stress characerization is called with individual
%   configurations.
%   The characterized stress values are then stored inside the
%   stressCharacterization object and used afterwards in the calcAging 
%   function.
%
%   2017-08-04   Maik Naumann
%%
function [ ees ] = characterizeStress( ees )

% If aging should be neglected with agingModelType 'NoAging', no stress
% characterization is executed and consequently no aging is calculated
if(strcmp(ees.inputTech.typeAgingMdl, 'no aging'))
    % No stress characterization is executed in this case

% If other aging models are selected, stress characterization is executed
% as defined with the stressCharacterization object SC inside EES
else
    % Check if final simulation step
    if ees.tNow == ees.inputSim.simEnd
        finalSimLoop = true;
    else 
        finalSimLoop = false;
    end

    % Initalize once in first simulation step
    if(ees.kNow == 1)
        % Characterization setup
        ees.stressCharacterization.Data2beCharacterized   = eval(ees.stressCharacterization.evalInitData2beCharacterizedString); % [];

        % Call defined characterization method
        ees.stressCharacterization.CharacterizationMethod(ees.stressCharacterization);

    % Call stress characterization at the end of simulation with special data selection
    elseif(finalSimLoop)
        % Characterization setup
        ees.stressCharacterization.finalSimLoop           = true;
        if ees.kNow > ees.inputSim.simEnd
            ees.kNow = ees.inputSim.simEnd;
        end
        ees.stressCharacterization.Data2beCharacterized   = eval(ees.stressCharacterization.evalLastSimLoopData2beCharacterizedString);

        % Call defined characterization method
        ees.stressCharacterization.CharacterizationMethod(ees.stressCharacterization);

    % Call stress characterization with data selection by defined step size 
    elseif(mod(ees.kNow, ees.inputTech.stepSzStressCharact) == 0)   
        % Characterization setup
        ees.stressCharacterization.Data2beCharacterized   = eval(ees.stressCharacterization.evalData2beCharacterizedString); %Data2beCharacterized; [time, value]

        % Call defined characterization method
        ees.stressCharacterization.CharacterizationMethod(ees.stressCharacterization);
    end

end

