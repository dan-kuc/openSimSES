%% createFcrData
% 
% Create data for fcr simulation with standard settings
%
% 2018-09-13 Daniel Kucevic
% 2019-05-12 Stefan Englberger

%%

function [ inputFcr ] = createFcrData( varargin )

%% input parsing
p = inputParser;
defVal = NaN;

addParameter(p,     'inputFcr',     defVal);
addParameter(p,     'inputTech',    defVal);
addParameter(p,     'inputSim',    defVal);
addParameter(p,     'inputMultiUse',defVal);

parse(p, varargin{:})

inputFcr      = p.Results.inputFcr;
inputTech     = p.Results.inputTech;
inputMultiUse = p.Results.inputMultiUse;
inputSim      = p.Results.inputSim;

%% Define frequency control settings
% Settings according to 2014_04_03_Eckpunkte_Freiheitsgrade_Erbringung_PRL.pdf
% warning('FCR data according to 2014_04_03_Eckpunkte_Freiheitsgrade_Erbringung_PRL.pdf. Changes need to be done in script.')
inputFcr.frequencySet            = 50;   % [Hz] Nominal grid frequency in UCTE grid
inputFcr.frequencySlopeSet       = -5;   % [s] Slope of frequency control according to FCR regulations %-> Offset = 200 mHz
inputFcr.frequencyDeadTime       = 30;   % [s] Dead time to control frequency change
inputFcr.frequencyDeadBand       = 0.01; % [Hz] 10 mHz frequency dead band in positive and negative direction 
inputFcr.overfulfillmentFactor   = 1.2;  % [pu] Overfulfilment factor in relation to maximum POCR power for frequency control

%% Define SOC set value by considering efficiency losses in half cycle
% eta is assumed to be constant. SOC is adapted to average efficiency to compensate the losses.
if(size(inputTech.etaBatt) > 1)
    eta             = mean(inputTech.etaInverter * inputTech.etaBatt(1,2)); 
else
    eta             = mean(inputTech.etaInverter * inputTech.etaBatt(1));   
end
efficiencyOffset    = (1 - eta) / 2; % offset to be added to 50% SOC to compensate efficiency losses
inputFcr.eta        = eta;
inputFcr.socSet     = 0.5 + efficiencyOffset; % target SOC for single use



% Offset time for IDM transaction to control SOC
if(inputFcr.flagNewRegulations)
    % Settings according to 2015_09_29_Anforderungen_Speicherkapazitaet_Batterien_PRL)
    inputFcr.idmOffsetTime  = 30 * 60; % [s]
else
    % Old Settings according to 2014_04_03_Eckpunkte_Freiheitsgrade_Erbringung_PRL.pdf
    inputFcr.idmOffsetTime  = 15 * 60; % [s]
end

% Defintion of maximum fcr power
inputFcr.fcrMax             = inputFcr.power2EnergyRatio * inputTech.eBattNom/3600; % [W]

                    
%% Definition of parameters for IDM transactions 
% Settings according to regulations of EPEX since 16.07.2015
inputFcr.idmTransactionTimeInterval  = 15 * 60; % [s] Time step for transactions at IDM
% Specifiy lead time for IDM transactions: 
inputFcr.idmTimeBuy                  = 30 * 60; % [s]        
inputFcr.idmTimeSell                 = 30 * 60; % [s]
inputFcr.idmIndexOffset              = inputFcr.idmTimeBuy / inputFcr.idmTransactionTimeInterval;
% Specifiy minimal idm transaction volume 
inputFcr.idmMinimalTransactionVolume = 1e5;% * inputFcr.idmTransactionTimeInterval; % [Ws]
% Guess time for first idm transaction
inputFcr.idmFirstGuessTime           = 1/2/0.05; % [s]
                                               
end