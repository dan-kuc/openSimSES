%% setupEtaBatt
% Sub-Creator method to obtain efficiency vector for battery cell.
%
% creates array struct to assign powerBatt to according powerSOC. Done to
% consider losses within cell (rated capacity effect). Function is called
% during the parameterization at the first simulation step.
%
% Careful with very large power electronics. Extrapolation of battery
% efficiency may occur --> check if eta is within measured/expected values.
%
% 2017-08-03 Truong
% 2018-12-13 Update: Kucevic
%
%%

function [ ees ] = setupEtaBatt( ees )
% creates struct to assign powerBatt to dSOC
etaInput    = ees.inputTech.etaBatt;
inputSize   = size(etaInput);
nEtaOut     = ees.inputTech.etaAccuracy;

% etaInput with discrete efficiency values according to given power ratios for charge and discharge direction
if all(inputSize > 1) 
    % 1st column is c-rate, 2nd column is according efficiency
    if inputSize(1) < inputSize(2)
        etaInput = etaInput.';
    end
    % read values
    cRateMax    = ees.inputTech.pBattNom/ees.inputTech.eBattNom*3600;
    cRateIn     = etaInput(:,1);
    etaIn       = etaInput(:,2);
    % create disch. efficiency
    cRateNeg    = [cRateIn(cRateIn <= 0); 0];
    negEta      = [etaIn(cRateIn <= 0); 1];
    negEta      = interp1(cRateNeg, negEta, linspace(-cRateMax,0,nEtaOut + 1),'phchip');
    negEta      = min(1, negEta);
    % create charg. efficiency
    cRatePos    = [0; cRateIn(cRateIn >= 0)];
    posEta      = [1; etaIn(cRateIn >= 0)]; %etaInput(etaInput(:,1) >= 0, :);
    posEta      = interp1(cRatePos, posEta, linspace(0,cRateMax,nEtaOut + 1),'phchip');
    posEta      = min(1, posEta);
    % conc. efficiency
    etaBatt     = [1./negEta, posEta(2:end)]; 
    if sum(etaBatt == 1) > 1
        warning('Efficiency of 1 for battery. Please check efficiency.')
    end

% etaInput with discrete efficiency values according to power ratio between 0 and 1 of charge direction
elseif any(inputSize > 1)
    warning('No c-rate is given to respective efficiencies of battery. May be distorted. Check input parameters.')
%     x           = linspace(0, EES.inputTech.battRatedPower, EES.inputTech.etaAccuracy + 1); 
%     etaInput_x  = linspace(0, EES.inputTech.battRatedPower, length(etaInput));
%     negEta      = interp1(etaInput_x, 1./etaInput, x);
%     negEta      = negEta(end:-1:2);
%     posEta      = interp1(etaInput_x, etaInput, x);
%     etaBatt     = [negEta, posEta];
    cRateMax    = ees.inputTech.pBattNom/ees.inputTech.eBattNom*3600;
    negEta      = etaInput(etaInput(:,1) <= 0, :);
    negEta      = interp1(negEta(:,1), negEta(:,2), linspace(-cRateMax,0,nEtaOut + 1),'phchip');
    negEta      = min(1, negEta);
    
    posEta      = etaInput(etaInput(:,1) >= 0, :);
    posEta      = interp1(posEta(:,1), posEta(:,2), linspace(0,cRateMax,nEtaOut + 1),'phchip');
    posEta      = min(1, posEta);
    
    etaBatt     = [1./negEta, posEta(2:end)]; 
    if any(etaBatt == 1)
        warning('Efficiency of 1 for battery. Please check efficiency.')
    end
    
% constant eta without power dependency    
else 
    negEta      = repmat(1./etaInput, 1, nEtaOut);
    posEta      = repmat(etaInput, 1, nEtaOut + 1);
    etaBatt     = [negEta, posEta];
end

% Write into object
ees.etaBatt     = etaBatt(:);

end % end of function

