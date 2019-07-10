%% addRequiredPaths
% Script to add relevant folder into Matlab's search path in order to
% correctly access scripts and functions.
%
%
% 2018-12-18 Kucevic Daniel
%%

function addRequiredPaths()
    % Add all paths
    addpath(genpath(fileparts(which('addRequiredPaths.m'))));
    
end



