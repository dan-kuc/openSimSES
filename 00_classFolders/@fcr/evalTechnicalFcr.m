%% evalTechnicalFcr
%   Function computes technical results for a FCR storage.
%   Energy balances of BESS, grid and all applied applications are computed.
%   Result of evalTechnical are included in output struct.
%
% 2017-01-05 Maik Naumann
% 2019-07-08 Daniel Kucevic
%%
function [ ees ] = evalTechnicalFcr( ees )
    
%% Assign input parameters
tSample         = ees.inputSim.tSample;
fcrLoad         = ees.fcrData.fcrLoad;
idmLoad         = ees.fcrData.idmOut;


% evaluation of technical storage data (application independent)
result          = evalTechnical( ees );

% FCR supply: Calculate power and energy exchange due to FCR power supply
pFcrPositive =   max(fcrLoad, 0);    % [W] power feed-in into grid
pFcrNegative = - min(fcrLoad, 0);    % [W] power drawn from grid
eFcrPositive = sum( pFcrPositive ) * tSample; % [Ws] energy feed-in into grid 
eFcrNegative = sum( pFcrNegative ) * tSample; % [Ws] energy drawn from grid
    
% IDM transactions: Calculate power and energy exchange due to FCR power supply
pIdmSold    =   max(idmLoad, 0);                    % [W] power feed-in into grid
pIdmBought  = - min(idmLoad, 0);                    % [W] power drawn from grid
eIdmSold    = sum( pIdmSold ) * tSample;     % [Ws] energy feed-in into grid 
eIdmBought  = sum( pIdmBought ) * tSample;   % [Ws] energy drawn from grid
   

%% Assign local vars into output struct
% FCR supply
result.fcr___       = [];
result.eFcrPositive = eFcrPositive;
result.eFcrNegative = eFcrNegative;

% IDM transactions
result.idm___       = [];
result.eIdmSold     = eIdmSold;
result.eIdmBought   = eIdmBought;

ees.resultsTechnicalFcr = result; 
end