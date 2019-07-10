%% getPInverter
% Calculates output power of inverter with given input. Positive values are
% power from AC to DC, negative values denote power flow from DC side to AC
% side.
% Efficiency curve determines, whether pOut is AC or DC side.
%
% Output ===
% pOut          [W] power to be calculated
%
% Input ===
% pAC           [W] power input
% pInverterNom  [W] rated power of inverter
% etaInverter   [pu] efficiency curve from -pInverterNom to +pInverterNom

% 2018-02-27 Truong
%   Update: 2019-07-08 Daniel Kucevic
%%

function [ pOut, pIn ] = getPInverter( pInRef, pInverterNom, etaInverter )

% obtain helping var to index correct eta value
nEta    = (length(etaInverter)-1)/2;

% limit AC input to rated power
pIn     = min(pInRef, pInverterNom);                    % pAC is at limit
pIn     = max(pIn, -pInverterNom*etaInverter(end));     % pDC is at limit

% calculate power at DC output
etaIdx  = max(1,ceil(nEta * (pIn ./ pInverterNom + 1)));   % locate idx of efficiency array
etaNow  = etaInverter(etaIdx);                          % obtain respective efficiency
if etaNow == 0
    fCorrect = sign(pIn);
    etaNow = etaInverter(etaIdx+fCorrect);
end
pOut    = etaNow .* pIn;                                % get DC power

end

