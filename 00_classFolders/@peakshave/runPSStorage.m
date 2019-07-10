%% runPSStorage
% Method of PS class to simulate object with ps settings. OS is
% predetermined by fhandle during instantiation of class object. 
%
% Input ==
% ees [-] residential class object
%
% Output ==
% ees [-] residential class object
%
% Method is equivalent to Simulink model where the storage system object is
% called each timestep and fed with input power. 
%
%   2019-05-12 Stefan Englberger
% Update 2019-07-05 Daniel Kucevic
%%

function [ ees ] = runPSStorage( ees )                                 % Renamed 
    %% run OS (fhandle)
    ees.inputTech.osStorage( ees );
    
    %% calculate relevant power flows (load with BESS)
    pPSGrid     = ees.inputPSProfiles.load(:) + ees.pStorage(:);      % compute load with BESS

    %% write results into object
    ees.pPSGrid    = pPSGrid(:);                                         % compute  load after peak shaving

end

