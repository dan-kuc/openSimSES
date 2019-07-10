function [ ] = plotSOC( ees, varargin )
%plotSOCandSOH plots the SOC and the SOH of the storage into one plot. Is
%called by plotStorageData()
%
% INPUTS 
%   EES: Storage object (obligatory)
%   axis: axis handle
%   profileTime
%   stepVector
% OUTPUTS: none
% STATUS: functioning
% LAST UPDATED: 15.01.2018
% OWNER: Markus Förstl


p = inputParser;

defVal = nan;

addParameter(p, 'axis', defVal); 
addParameter(p, 'rightaxis', false);

parse(p, varargin{:}); 

axis        = p.Results.axis; 
rightaxis   = p.Results.rightaxis;

if ~isgraphics(axis)
    screensize  = get( groot, 'Screensize' );
    hFig        = figure('Position',[80 20 screensize(3)*0.95 screensize(4)*0.9]);
    set(hFig,'Color','w');
    axis = gca;
end

if rightaxis
    hold(axis,'on')
    yyaxis(axis, 'right')
end

x2SEC = 3600*24;
soc = ees.SOC;

inputSim    = ees.inputSim;
time        = linspace(inputSim.simStart, inputSim.simEnd/x2SEC, length(soc));
time        = time(:);

plot(axis, time, soc, ':'); 
xlim(axis, [time(1) time(end)]);
hold(axis,'off')

end

