%% createProfiles
% Scales given profiles for simulation of simSES Object. Either energy of
% profile or peak value is adapted.
%
% Input == (parameters)
% profile       [W]     input profile to be scaled
% profileEnergy [Ws]    desired energy of power profile during profile period
% profilePeak   [W]     desired peak value of profile
% profilePeriod [s]     time length of input profile
% simPeriod     [s]     time period of simulation
% sampleTime    [s]     sample time for simulation
%
% 
% Output == 
% profile       [W]     profile of profile used for simulation
%
%
% Profiles are created based on technical input data. Profiles are
% replicated or shortened to match simulation period. 
% Scaling to desired peakpower or profile energy within profile period
% either peakPower or profileEnergy can be set, not both.
%
% 2 optional methods are possible for profile scaling:
%   1. scaling of peak of profile to given peak power
%   2. scaling of profile to match profile's sum to given profileEnergy.
%   Only time period of profile is considered for this calculation.
%
%
% 2015-12-21 Nam Truong    
%   Update: 2019-07-08 Daniel Kucevic
%
%%

function [ profile ] = createProfiles( varargin )
%% parse input parameters
p       = inputParser;  % parser handle
defVal  = NaN;          % default value for parsing
% add parameters accepted for input
addParameter(p, 'profile',      defVal)
addParameter(p, 'eProfile',     defVal)
addParameter(p, 'pPeakProfile', defVal)
addParameter(p, 'tProfile',     defVal)
addParameter(p, 'tSim',         defVal)
addParameter(p, 'tSample',      defVal)
% parse input
parse(p, varargin{:})
% write parsed input into local var
inputProfile    = p.Results.profile;
eProfile        = p.Results.eProfile;
pPeakProfile    = p.Results.pPeakProfile;
tProfile        = p.Results.tProfile;
tSim            = p.Results.tSim;
tSample         = p.Results.tSample;

%% scaling of profile
% generation of x-vector
outputProfileLength = floor(linspace(1, length(inputProfile),(tProfile/tSample)));

% sampling of loadProfile
profile_x       = 1:length(inputProfile);
profile         = interp1(profile_x, inputProfile, outputProfileLength);

%% Determine task of function
% if neither profilePeak or profileEnergy is set, profile is just adapted
% to simulation period and sample time
if any(strcmp(p.UsingDefaults,'pPeakProfile')) && any(strcmp(p.UsingDefaults,'eProfile'))
% if 'profileEnergy' is set, profile is scaled until sum of profile matches 
% profileEnergy. profilePeriod is regarded to match that sum.
elseif any(strcmp(p.UsingDefaults,'pPeakProfile'))
    profile     = profile* eProfile/(sum(profile)*tSample); 
% if 'peakPower' is set, profile is scaled to match peak power
elseif any(strcmp(p.UsingDefaults,'eProfile'))
    profile     = pPeakProfile / max(profile) * profile;     
% of both 'peakPower' and 'profileEnergy' are set --> unclear calculation
else
    error([mfilename('fullpath') ': Ambiguous parameter specification. Profile energy and peak power cannot be set at the same time.'])
end

% create length and cut to desired simulation period
profile     = repmat(profile(:), ceil(tSim(2)/tProfile), 1);
profile     = profile(floor(tSim(1)/tSample)+1:(tSim(2)/tSample));

    

end

