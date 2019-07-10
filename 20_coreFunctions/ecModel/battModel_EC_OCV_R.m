%% fPI_OCV_R
% OCV + R Equivalent Circuit Cell model with Power as Input Equivalent
% Circut Model which is based on Open Circuit Voltage (SOC depending) and 1
% Resistor (SOC & Temperature depending)
%
% Input ==
% pReq              [W]         reference power that is required at output
% sampleT           [s]         length of simulation time step
% socIn             [p.u.]      current SOC
% sohC              [p.u.]      current SOH of capacity
% sohR              [p.u.]      soh of innerresistance 
% tempBatt          [K]         temperature of cell
% modelParam        [-]         struct with battery parameters
% battSelfDischRate [p.u. / s]  self discharge rate of cell
%
% Output ==
% pOut              [W]         actual output power
% pLoss             [W]         power loss
% ocv0              [V]         voltage of OCV
% uBatt             [V]         voltage at battery terminal
% iBatt             [A]         current
% socOut            [p.u.]      resulting SOC
% eta               [p.u.]      efficiency
% ri                [V/A]       inner resistance at operation point
%
% To be handed over to object during instantiation as function handle for
% the battery model. Function is called every time the simulation object is
% updated for the object.
%
% 2017-08-07 Schimpe / Truong
%   Update: 2019-07-08 Daniel Kucevic
%%

function[pOut, pLoss, ocv0, uBatt, iBatt, socOut, eta, ri, eLossSelfDisNow] = battModel_EC_OCV_R(pReq, sampleT, socIn, sohC, sohR, tempBatt, modelParam, eBattNom, battSelfDischRate)

ocvAccuracy = modelParam.ocvAccuracy;
ahCap       = modelParam.qNom * sohC;
riAccuracy  = modelParam.riAccuracy;
% If SOC_0 is a little below zero due to rounding errors, set it to 0
if socIn < 0 && socIn >= -eps
    socIn = 0;
end

%% Interpolate Open Circuit Voltage from Temperature and SOC
idxOcv  = max( 1, floor( socIn * ocvAccuracy ) );     % find idx for corresponding ocv
ocv0    = modelParam.ocv( idxOcv );

%% Interpolate R_i from Temperature and SOC and Power Direction
idxSoc  = max( 1, floor( socIn * riAccuracy ) );
% Compute discharge case
if pReq < 0
    idxTemp = round( ( tempBatt - modelParam.riDischTMin ) * riAccuracy / ( modelParam.riDischTMax - modelParam.riDischTMin )  );
    idxTemp = min(idxTemp, riAccuracy);
    % Get R_i dependet on SOC and temperature and scale with SOH_Resistance
    ri      = modelParam.riDisch( idxSoc, idxTemp ) * (2-sohR);
    % Result from R_Load=R_i ==> Theoretical maximum discharge Power
    % without regards to min. Voltage etc. + tolerance for numerical
    % reasons
    pMaxDisch   = -(ocv0^2)/(4 * ri) + 1e-9; %TODO How is this arrived at?
    pReq        = max(pReq, pMaxDisch);
    iReq_sqrt   = sqrt( ocv0^2 + 4 * ri * pReq ); % TODO This is the sq root term of the solution to a quadratic equation which solves for current, given OCV, Ri and power at terminal. x = {-b +- root(b2 - 4ac)}/2a
    % Calculate corresponding I for the requested Power
    iReq1 = ( -ocv0 + iReq_sqrt )/( 2 * ri );
    iReq2 = ( -ocv0 - iReq_sqrt )/( 2 * ri );
    if iReq1 > 0
        iReq = iReq2;
    else            
        iReq = max(iReq2, iReq1);
    end
    
% compute charge case
else 
    idxTemp = round( ( tempBatt - modelParam.riChTMin ) * riAccuracy / ( modelParam.riChTMax - modelParam.riChTMin )  );
    idxTemp = min(idxTemp, riAccuracy);
    ri      = modelParam.riCh( idxSoc, idxTemp )* (2-sohR);
    % Calculate corresponding I for the requested Power  
    iReq_sqrt   = sqrt( ocv0^2 + 4 * ri * pReq );    % This is the sq root term for the solution of a quadratic equation
    iReq1 = ( -ocv0 - iReq_sqrt )/( 2*ri );
    iReq2 = ( -ocv0 + iReq_sqrt )/( 2*ri );
    if iReq1 < 0
        iReq = iReq2;
    else
        iReq = min(iReq2, iReq1);
    end
    
end

%% calculate max current

% Calculate  I_Min_SOC I_Max_SOC from SOC_Min & SOC_Max Criteria
iMinSoc = - max( socIn - modelParam.socMin, 0 ) * ahCap / sampleT;
iMaxSoc =   max( modelParam.socMax - socIn, 0 ) * ahCap / ( modelParam.etaCoul * sampleT );

%% Calc new SOC
% Compare iReq with iMinV, iMinSoc, iMinExt, iMaxV, iMaxSoc, and iMaxExt
if pReq < 0 % Discharge
    
    iBatt   = max([iReq,iMinSoc, modelParam.iMinExt]);
    socOut  = socIn + iBatt * sampleT / ahCap ;
else        % Charge
    iBatt   = min([iReq,iMaxSoc,modelParam.iMaxExt]);
    socOut  = socIn + iBatt * sampleT / ahCap * modelParam.etaCoul;
end

%% Calc self discharge rate
% Assumption: Self discharge occurs always: Equally in idle periods
if socOut > 0
    socOut = socOut - battSelfDischRate * sampleT;
    eLossSelfDisNow = abs(battSelfDischRate * sampleT * eBattNom); 
else
    eLossSelfDisNow = 0; 
end

%% Calculate output
uBatt    = ocv0 + ri * iBatt;
pOutideal= ocv0 * iBatt;
pOut    = uBatt * iBatt;
%Calc P Loss
pLoss   = abs(pOutideal-pOut);
%Calc eta
if pOut == 0
    eta = 1;
else
%     eta = abs(pOut)/abs(pOutideal);
      eta = ( abs( pOut ) - abs( pLoss ) )/abs( pOut );
end

% If SOC_0 is a little below zero due to rounding errors, set it to 0
if socOut < 0
    socOut = 0;
end


%% Check for calculation errors
if isreal(iReq) == 0
    error('not real I_REQ');
end
if isnan(pOut)
    error('NAN  Power in fPI OCV R')
end
if abs((socOut - socIn)*(ahCap) - iBatt * sampleT) >= ( eps*1e3 + battSelfDischRate * sampleT ) * ahCap
    error('SOC calculation not matching I*time')
end
if isnan(socOut)
    error('SOC from fPI_OCV_R < 0')
end
if pLoss < 0
    error('Power Loss < 0!')
end

end

