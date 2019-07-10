function [ ] = plotPieFcrFrr( ees, ax )
%plotPieFcrFrr plots a pie diagram of the different power flows
%   Fct is called by plotAging()
%   Input:  ees object
%           axis: specified axis in subplot
%           figureSettings: struct for formatting
% OUTPUTS: h
% STATUS: functioning.
% LAST UPDATED: 2018-10-09
% OWNER: Daniel Kucevic

%% Get default figure settings
run('figureSettingsDefault.m')

%% Get data from ees object
% +0.01 MW to get no errors if there is no idc/frr transaction
fcrLoad     =    sum(abs(ees.fcrData.fcrLoad))+0.01; % Watt
idcLoad     =    sum(abs(ees.fcrData.idcLoad))+0.01; % Watt
frrLoad     =    sum(abs(ees.frrData.frrLoad))+0.01; % Watt

data = [fcrLoad idcLoad frrLoad];

% plot pie diagram
labels = {'FCR transactions','IDC transactions','FRR transactions'};
p = pie(ax,data,labels);
p(1).FaceColor  = colors(2,:);
p(2).FontName = 'Arial';
p(2).FontSize = 12;
p(3).FaceColor  = colors(3,:);
p(4).FontName = 'Arial';
p(4).FontSize = 12;
p(5).FaceColor  = colors(4,:);
p(6).FontName = 'Arial';
p(6).FontSize = 12;
title(ax,'Share of various power flows', textstyle{:});


end

