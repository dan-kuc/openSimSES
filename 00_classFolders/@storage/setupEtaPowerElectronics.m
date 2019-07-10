%% createEtaPowerElectronics
%
% Sub-Creator method to obtain efficiency vector for power eletronics
% during object generation.
% Creates array struct to assign powerStorage to according powerBatt.
% 
%
%   Creates array struct to assign powerStorage to according powerBatt
%   after inverter efficiency losses. 
%   Following assumption: P_out = eta * P_in.
%   Usage if efficiency is however always P_batt = eta * P_storage
%   Efficiency needs to be inversed for negative power (discharge case) to
%   correctly calculate powers.
%   Function is called during parameterization at the first simulation
%   step.
%
% 2017-07-27 Nam Truong
%%----------------ADDITION OF NEW POWER ELECTRONICS METHOD: LOOK UP TABLE ('LUT')------------------------
% 2018-08-01 Anupam Parlikar 
% Update 2019-07-05 Daniel Kucevic
%%



function [ ees ] = setupEtaPowerElectronics( ees )

etaInput    = max(ees.inputTech.etaInverter, 0.1);
pPENom      = ees.inputTech.pInverterNom;

% eta curve = f(p)
if strcmp(ees.inputTech.inverterMethod,'lut') == 1
    PEeta_Ch            = ees.inputTech.etaInverter_Ch;
    PEeta_Disch         = ees.inputTech.etaInverter_Dis;
    etaIn_pAc_Ch        = linspace( 0, pPENom, length(PEeta_Ch) );                % get x-axis for given eta-Input (assume that etaInput is evenly distributed)
    x_Ch                = linspace( 0, pPENom, ees.inputTech.etaAccuracy + 1 );   % creates x with length of EES.etaAccuracy + 1 (for 0 value)
    posEta              = interp1( etaIn_pAc_Ch, PEeta_Ch, x_Ch);
    
    etaOut_pDc_Disch    = linspace( 0, pPENom, length(PEeta_Disch) );
    x_Disch             = linspace( 0, pPENom, ees.inputTech.etaAccuracy + 1 );
    negEta              = interp1( etaOut_pDc_Disch, 1 ./ PEeta_Disch, x_Disch);

    negEta              = negEta( end:-1:2 );
    etaPE               = [negEta, posEta];
    etaPE(etaPE==inf)   = 0;
    etaInv              = 1./etaPE;
    etaInv(etaInv==inf) = 0;

elseif length(etaInput) > 1
    % construct etaPE = f(pAc)
    etaIn_pAc   = linspace( 0, pPENom, length(etaInput) );    % get x-axis for given eta-Input (assume that etaInput is evenly distributed)
    x           = linspace( 0, pPENom, ees.inputTech.etaAccuracy + 1 ); % creates x with length of EES.etaAccuracy + 1 (for 0 value)
    negEta      = interp1( etaIn_pAc, 1 ./ etaInput, x );   % create interpolated efficiency curve for negative values
    negEta      = negEta( end:-1:2 );                       % reverse order of curve for correct total efficiency curve
    posEta      = interp1( etaIn_pAc, etaInput, x );        % interpolate to given fidelity (etaAccuracy)
    etaPE       = [ negEta, posEta ];                       % concat negative and positive efficiency curves

    % construct etaInv = f(pDc) for correction-mechanism in setPower-Method
    pAcIn   = [-x(end:-1:2), x];   
    pDcIn   = pAcIn.*etaPE;
    
    % limit pDc during discharge to PERatedPower
    pDcT    = min( pDcIn,  pPENom);
    pDcT    = max( pDcT,  -pPENom);
    
    % create even space of input pDc
    pDcNeg  = linspace( pDcT(1), 0, ceil(length(pDcIn)/2));
    pDcPos  = linspace( 0, pDcT(end), ceil(length(pDcIn)/2));
    pDc     = [pDcNeg, pDcPos(2:end)];
    pAcNeg  = interp1( pDcIn, pAcIn, pDcNeg);
    pAcPos  = interp1( pDcIn, pAcIn, pDcPos);
    pAc     = [pAcNeg, pAcPos(2:end)];
    
    % create inverse of efficiency curve for discharge case
    etaInv  = pAc ./ pDc;
    etaInv(isnan(etaInv)) = 0;
 
% constant eta without power dependency
else 
    negEta  = repmat(1./etaInput, 1, ees.inputTech.etaAccuracy);
    posEta  = repmat(etaInput, 1, ees.inputTech.etaAccuracy + 1);
    etaPE   = [negEta, posEta];
    etaInv  = fliplr(etaPE);
end

% write into object
ees.etaInverter     = etaPE(:); 
ees.etaInverterInv  = etaInv(:); 

end

