switch strat_pe
    case 'uniform'
        nEta    = (length(etaInverter)-1)/2;
        % limit AC input to rated power
        pIn_Individual     = min(pInRef_Individual, pInverterNom_Individual);                    % pAC is at limit
        pIn_Individual     = max(pIn_Individual, -pInverterNom_Individual*etaInverter(end));     % pDC is at limit

        % calculate power at DC output
        etaIdx  = max(1,ceil(nEta * (pIn_Individual ./ pInverterNom_Individual + 1)));   % locate idx of efficiency array
        etaNow  = etaInverter(etaIdx);                          % obtain respective efficiency
        if etaNow == 0
            fCorrect = sign(pIn_Individual);
            etaNow = etaInverter(etaIdx+fCorrect);
        end
        pOut_Individual    = etaNow .* pIn_Individual;                                % get DC power
        pOut               = pOut_Individual*inverterNumber;
        
    case 'cascaded non-uniform'
        pIn_Individual=zeros(inverterNumber,1);
        nEta    = (length(etaInverter)-1)/2;
        
        pIn_Individual     = min(pInRef_Individual, pInverterNom_Individual);
        pIn_Individual     = max(pIn_Individual, -pInverterNom_Individual*etaInverter(end));
        
         % calculate power at DC output
        etaIdx  = max(1,ceil(nEta * (pIn_Individual ./ pInverterNom_Individual + 1)));   % locate idx of efficiency array
        etaNow  = etaInverter(etaIdx);                          % obtain respective efficiency
        if etaNow == 0
            fCorrect = sign(pIn_Individual);
            etaNow = etaInverter(etaIdx+fCorrect);
        end
        pOut_Individual    = etaNow .* pIn_Individual;                                % get DC power
        pOut               = sum(pOut_Individual);
        pIn                = sum(pIn_Individual);
end