%% runStorage
%   Method of FCR class to simulate object with fcr settings. OS is
%   predetermined by fhandle during instantiation of class object. 
%
%   Input ==
%       EES [-] FCR class object
%
%   Output ==
%       EES [-] FCR class object
%
%   Method is equivalent to Simulink model where the storage system object is
%   called each timestep and fed with input power. 
%
%   2018-01-05 Naumann
%   Update 2019-07-05 Daniel Kucevic
%%
function [ ees ] = runFcrStorage( ees )
    %% run OS (fhandle)
    ees.inputTech.osStorage( ees );
    
    %% Calculate relevant power flows    
    tSim = (ees.inputSim.simEnd - ees.inputSim.simStart) / ees.inputSim.tSample;
    
    % Calculate net load after battery: Add to powerStorage the internal used power to supply the residential and external load
    pNet                 = ees.pStorage(2:end)';
    
    %% Write results into object
    ees.pGridExchange   = pNet;

end

