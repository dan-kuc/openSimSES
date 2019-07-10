function [ h ] = plotMultiUseLoadProfile_v2( ees, axis, profileTime, stepVector)
%plotMultiUseLoadProfile plots the load profile of the active power with and without BESS. 
%
%   2019-05-13 Stefan Englberger

%% Get default figure settings
run('figureSettingsDefault.m')

rgbMatrix =  [0.3000 0.7500 0.9000;                         % IDC
             0.0000 0.4470 0.8410;                          % FCR
             0.4940 0.1840 0.5560;                          % PS FTM
             0.0000 0.0000 0.0000;                          % FTM active Power
             0.8500 0.3250 0.0980;                          % PS BTM
             0.9290 0.6940 0.1250;                          % SCI
             0.2660 0.4740 0.1000;                          % qComp
             0.0000 1.0000 0.0000;                          % qAvailable
             0.7000 1.0000 0.0000;                          % qGrid 
             0.0000 0.0000 0.0000;                          % BTM active Power
             0.6000 0.6000 0.6000;                          % Power factor WO QC
             0.0000 0.0000 0.0000;                          % Power factor with QC
             0.6000 0.6000 0.6000;                          % Load WO BESS
             0.3000 0.3000 0.3000];                         % Load with BESS

% if ees.inputMultiUse.flagPsBtm
    powerPs     = ees.pStorage(:,1); 
%     powerSci    = ees.pStorageBtm(:,2);
%     powerPsSci  = powerPs + powerSci;                       % PS and SCI are part of BTM calculations
% else
%     powerPs     = ees.powerFtmAssigned(:,2);                % PS is part of FTM calculations
%     powerSci    = ees.pStorageBtm(:);                       % SCI is the only BTM application
%     powerPsSci  = powerPs + powerSci;                       % Power for PS and Sci
% end

LoadWoBess      = ees.inputPSProfiles.load/1000;                        % powerResidual equals load minus generation
LoadWBess       = ees.pPSGrid/1000;           % Load with BESS equals residual power plus PS and SCI power     
pThresh         = ees.inputTech.pPeakShaveThresh/1000;           % Threshhold for PS application
% Define maximum y value
maxLoadWoBess   = max(LoadWoBess);
maxLoadWBess    = max(LoadWBess);
maxLoad         = max(maxLoadWoBess, maxLoadWBess);
maxLoad         = max(maxLoad, pThresh);
% Define minimum y value
minLoadWoBess   = min(LoadWoBess);
minLoadWBess    = min(LoadWBess);
minLoad         = min(minLoadWoBess, minLoadWBess);
minLoad         = min(minLoad, pThresh);

hold(axis, 'on')
grid(axis, 'on'); 
box(axis, 'on');

h(1) = plot(axis, profileTime, LoadWoBess(stepVector));
h(2) = plot(axis, profileTime, LoadWBess(stepVector));
h(3) = refline(axis,[0 pThresh]);
h(1).Color = rgbMatrix(13,:);
h(1).LineStyle = ':';
h(2).Color = rgbMatrix(14,:);
h(3).Color = 'r';
h(3).LineStyle = '--';
    
l = legend(axis, 'Load w/o BESS', 'Load with BESS', 'PS^{threshold}'); 
set(l, 'Location', 'south', 'Orientation','horizontal', 'NumColumns',3, textstyle{:});
set(l.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.7]));

ylim(axis, [minLoad, maxLoad]);
ylabel(axis, 'Residual load / kW', textstyle{:});
grid(axis, 'on'); 
hold(axis, 'off'); 

%set(gca,'LooseInset',get(gca,'TightInset')); a = get(gca,'Position'); set(gca,'Position',[a(1)+0.005 a(2) a(3)-0.010 a(4)-0.005]);

% Create textbox
annotation('textbox',...
	[0.127527216174184 0.782068785591731 0.230171066698724 0.13756613504319],...
	'Color',[1 0 0],...
	'String',{'PS^{threshold} = 64 kW'},...
	'EdgeColor','none');

% Create arrow
annotation('arrow',[0.135303265940902 0.105754276827372],...
	[0.803232804232804 0.719576719576719],'Color',[1 0 0],'HeadWidth',7,...
	'HeadLength',7);

end