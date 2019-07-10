function out = convtime( in, uin, uout )
%  CONVTIME Convert from time units to desired time units or from rate
%  units to desired rate units.
%   OUT = CONVTIME( IN, UI, UO ) converts the input time or rate IN
%   (floating point array) from unit specified in UI (string) to unit
%   specified in UO (string). 
% 
%   EDIT BY MARKUS F�RSTL 
%       in this script: one year equals 365 days, not 365.25 as previously
%       plus: added plurals of day, week, year
% 
%   Allowable UI and UO strings (not case sensitive):
%      'ns'                  :nanosecond
%      'us','�s'             :microsecond
%      'ms'                  :milisecond     
%      's','sec'             :second
%      'm','min'             :minute
%      'h','hr','hour'       :hour
%      'd','day'             :day     
%      'wk','week'           :week
%      'y','yr','year'       :year (365 days)
%      'dec','decade'        :decade
%      'cent','century'      :century
%      'millen','millennium' :millennium
%
%   To convert in units of rate instead of units of time, add '/' to the
%   beginning of UI and UO, e.g. '/year' or '/min'. UI and UO (if
%   specified) may be of opposite unit type (time or rate). Use this to
%   convert units/unit_time to time_elapsed/unit or vice-versa (see
%   example).
%
%   If UO is not specified, IN is converted from UI to the SI unit,
%   seconds, or /second if UI is a rate unit.
%   
%   Examples:
%
%   Convert a matrix of time values from years to hours:
%       out = convtime([1 3; 4 5], 'year', 'hr')
%
%   Convert flow rate 0.2 gallons/second to gallons/day:
%       out = convtime(0.2, '/s', '/day')
%
%   Convert fuel burn rate 5000 lbm/hour to kg/s using aerospace toolbox:
%       out = convtime( convmass(5000,'lbm','kg'),'/hour','/s' )
% 
%   If manufacturing 800 items per hour, find how many seconds are required
%   to manufacture an item (convert 800 items/hour to seconds/item):
%       out = convtime(800, '/h', 's')
% 
%   If 65 seconds elapse between mile markers on the highway, find the
%   speed in miles/hour:
%       speed = convtime(65, 'sec', '/hour')
%
%   In aerospace toolbox:
%   See also CONVACC, CONVANG, CONVANGACC, CONVANGVEL, CONVDENSITY,
%   CONVFORCE, CONVLENGTH, CONVMASS, CONVPRES, CONVTEMP, CONVVEL.
%
%   Author: Sky Sartorius
%           sky.sartorius@gmail.com

if ~isfloat( in )
    error('Input is not floating point');
end

if nargin < 3 && uin(1) == '/';
    uout = '/s';
elseif nargin < 3
    uout = 's';
end

ratein = false;
rateout = false;
if uin(1) == '/'
    ratein = true;
    uin(1) = [];
end
if uout(1) == '/'
    rateout = true;
    uout(1) = [];
end

%{
          { 'ns'    1e-9
            'us'    1e-6
            '�s'    .001
            'ms'    .001 %s/ms
            's'     1
            'sec'   1
            'm'     60
            'min'   60 %s/min
            'h'     3600
            'hr'    3600
            'hour'  3600 %s/hr
            'd'     86400
            'day'   86400
            'days'  86400 %s/day
            'wk'    604800
            'week'  604800
            'weeks' 604800 %s/wk
            'y'          31536000
            'yr'         31536000
            'year'       31536000
            'years'      31536000 %s/yr
            'dec'        315360000
            'decade'     315360000 %s/decade
            'cent'       3153600000
            'century'    3153600000 %s/century
            'millen'     31536000000
            'millennium' 31536000000}; %s/millennium
%}
units = {'ns'
        'us'
        '�s'
        'ms'
        's'
        'sec'
        'seconds'
        'm'
        'min'
        'minutes'
        'h'
        'hr'
        'hour'
        'hours'
        'd'
        'day'
        'days'
        'wk'
        'week'
        'weeks'
        'y'
        'yr'
        'year'
        'years'
        'dec'
        'decade'
        'cent'
        'century'
        'millen'
        'millennium'};
    
constants = [1e-9
        1e-6
        1e-6
        .001 %s/ms
        1
        1
        1
        60
        60
        60 %s/min
        3600
        3600
        3600 
        3600 %s/hr
        86400
        86400 
        86400 %s/day
        604800
        604800 
        604800 %s/wk
        31536000
        31536000
        31536000 
        31536000 %s/yr
        315360000
        315360000 %s/decade
        3153600000
        3153600000 %s/century
        31536000000
        31536000000]; %s/millennium

islope = constants(strcmpi(uin,units))/constants(strcmpi(uout,units));

if ~isscalar(islope)
    error('invalid unit string(s)')
end

if ~ratein && ~rateout
    out = in*islope;
elseif ratein && rateout
    out = in/islope;
elseif ratein && ~rateout
    out = islope/in;
elseif ~ratein && rateout
    out = 1/(in*islope);
else
    error('Unknown time/rate combination')
end

% Revision history:
%       V1.0    14 July 2010
%       V2.0    26 July 2010
%           Added support for �s
%           Speed tests: .112 s tic;for ii =
%           1:1000;convtime(ii,'decade','century');end;toc;
%           .059 s same with new coding scheme
%       V3.0    8 August 2010
%           input units may now be of opposite type as output units (e.g.
%           rate in, time out). Appropriate examples added.
%           'sec' added