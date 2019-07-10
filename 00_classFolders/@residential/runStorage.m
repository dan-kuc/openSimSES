%% runStorage
% Method of residential class to simulate object in PV home setting. OS is
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
% 2019-07-05 Kucevic
%%

function [ ees ] = runStorage( ees )
    %% run OS (fhandle)
    ees.inputTech.osStorage( ees );
    
    %% calculate relevant power flows
    resLoad     = ees.inputProfiles.load(:) - ees.inputProfiles.genPV(:);  % compute residual load
    netLoad     = resLoad + ees.pStorage(:);                                % compute net load after battery
    pGrid       = max( netLoad, ees.inputTech.power2GridMax(1) );               % compute power drawn from grid (net load after curtailment)
    pCurtail    = pGrid - (netLoad);                                            % compute curtailment
    
    %% write results into object
    ees.powerGrid    = pGrid(:);
    ees.powerCurtail = pCurtail(:);

end

