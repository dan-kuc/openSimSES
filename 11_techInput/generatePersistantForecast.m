%% generatePersistantForecast
% Creates forecast profiles for given profile with persistance method.
% Actual profile is shifted. E.g. previous day or week is used as forecast.
%
% Input == (parameters)
% profile       [W]     input profile for shifting
% tPersist      [s]     persistance period for shifting (e.g. day before or week before)
% tSample       [s]     sampleTime of input profile
%
%
% Output ==
% fcProfile     [W]     array of generated forecast profile
%
%
% Profile is shifted to given persistancePeriod. Actual profile of previous 
% time is used as forecast.
%
% 2015-12-11 Nam Truong
%
%%

function [ fcProfile ] = generatePersistantForecast( varargin )
%% parse input parameters
p       = inputParser;  % parser handle
defVal  = NaN;          % default value for parsing
% add parameters accepted for input
addParameter(p, 'tPersist', defVal)
addParameter(p, 'profile',  defVal)
addParameter(p, 'tSample',  defVal)
% parse input
parse(p, varargin{:})
% write parsed input into local var
tPersist    = p.Results.tPersist;
profile     = p.Results.profile;
tSample     = p.Results.tSample;

%% usage of circshift to generate forecast
% calculate required shifts to meet requested time period
cirshiftSteps   = round(tPersist/tSample);
% generate persistant forecast 
fcProfile       = circshift(profile(:), cirshiftSteps, 1);

end
