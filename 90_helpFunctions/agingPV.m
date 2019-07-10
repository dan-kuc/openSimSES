%% agingPV
% Function scales given PV profile to consider output reduction due to PV
% cell aging.
%
% PVProfile = agingPV('param', 'value')
%
% Input == (parameters)
% simTime           [s]     simulation time
% PVProfile         [W]     input PV profile to be scaled
% PVagingPerYear    [pu]    aging per year
%
% Output ==
% PVProfile         [W]     Pv profile over the years with aging
%
% PV profile is downscaled for each simulation year for given annuel PV
% aging factor.
%
% 2015-12-01 Moritz Brauchle / Nam Truong
%
%%


function [PVprofile] = agingPV ( varargin )
%% Parsing of input
p = inputParser;    % generate parsing handle
defVal = NaN;       % define default value for missing input
% generate parameters
addParameter(p, 'tSim',     defVal);
addParameter(p, 'profile',  defVal);
addParameter(p, 'rAging',   defVal);
% parse input
parse(p, varargin{:})
% write parsed input into local vars
tSim    = p.Results.tSim;
profile = p.Results.profile; 
rAging  = p.Results.rAging;

%% Scaling of PVprofile to consider reduced output caused by aging
agingFactor = 1 - rAging;                                       % conversion to aging factor
simYears    = tSim / (3600*24*365);                                  % obtaining # of simulation years for scaling
timeVector  = linspace(0, max(1,simYears-1), length(profile));   % generate array with year #
pvAging     = agingFactor.^(timeVector);                                % compute array with aging factor for each simulation year
PVprofile   = profile.*pvAging(:);                                  % multiply PVprofile with aging factor array to obtain resulting PV profile

end



