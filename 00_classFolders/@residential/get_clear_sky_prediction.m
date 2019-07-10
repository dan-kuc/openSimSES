function fcGenPV = get_clear_sky_prediction(ees, kLookAhead)
% Helping variables
global gvarKWH2WS gvarDAYS2SECONDS gvarYEARS2SECONDS
fcGenPV         = ees.inputForecast.genPV;
tSample         = ees.inputSim.tSample;
kLookAhead(2)   = min(kLookAhead(2), length(ees.SOC));  % keep lookahead within limits
kLookAheadArr   = kLookAhead(1):1:kLookAhead(2);        % array of given range
nDays           = (diff(kLookAhead) + 1) .* tSample / gvarDAYS2SECONDS;    % # of days


if round(nDays) ~= nDays
    lRange          = ceil(nDays) / nDays * ( diff(kLookAhead) + 1 );
    kLookAheadArr   = fliplr(kLookAheadArr(end):-1:(kLookAheadArr(end)+1-lRange) );
    kLookAheadArr   = max(1, kLookAheadArr);
    kLookAheadArr   = unique( kLookAheadArr );
    kLookAhead(1)   = kLookAheadArr(1);
    kLookAhead(2)   = kLookAheadArr(end);
    nDays           = ceil(nDays);
end

steps   = reshape(kLookAheadArr,[],nDays);     % k of each day per column

kPerDay     = size(steps,1); 
inputTech   = ees.inputTech;
pPVnom      = inputTech.pPVnom;
dayNow      = floor(kLookAhead(1) / kPerDay) + 1;           % current day
if length(fcGenPV) < gvarYEARS2SECONDS/tSample          % workaround for simulation of only 30 days
    dayNowT = dayNow + 100;
end

kOfDay      = step_2_step_of_day(kLookAhead(1), kPerDay);   % k of current day
rClSky      = gen_clear_sky_pv(         ...
            dayNowT,                     ...
            kPerDay,                    ...
            inputTech.paramPVdegLat,    ...
            inputTech.paramPVangleIncl, ...
            inputTech.paramPVangleAzim  );                  % [pu] clear sky profile of current day
pClSky      = rClSky * pPVnom;                              % [W]  clear sky generation of current day

%% current time step be used for clear sky short term prediction
if pClSky(max(kOfDay-1, 1)) > 0
    % calculate indexing of arrays
    k0DayNow        = step_2_step0_of_day(kLookAhead(1), kPerDay);  % starting k of current day
    lPredShortT 	= inputTech.genPredTShortTerm / tSample;        % # of k for short term prediction interval
    kPredShortTArr  = kOfDay:(lPredShortT + kOfDay);                % index array for short term pred interval

    % estimate prediction rate from clear sky.
    pGenReal        = ees.inputProfiles.genPV(k0DayNow:(kOfDay-1)); % generation from start of day until now
    eGenReal        = sum(pGenReal)             * tSample;          % generated energy from start of day until now
    eGenClSky       = sum(pClSky(1:(kOfDay-1))) * tSample;          % clear sky generated energy from start of day until now
    rGenPred        = eGenReal / eGenClSky;                         % ratio of actually generated energy vs clear sky potential
    pPredClSky      = rGenPred * pClSky;                            % generate according clear sky generation

    % only calculate clear sky if nan is not an issue
    if ~isnan(rGenPred)
        % correct prediction, if overestimated --> limit to PVpeak
        rPredMax =  max(pPredClSky) / pPVnom;
        if rPredMax > 1
            pPredClSky = pPredClSky / rPredMax;
        end
        % replace original prediction with clear sky short term prediction
        fcGenPV(kPredShortTArr) = pPredClSky(kPredShortTArr);    
        ees.inputForecast.genPV(kPredShortTArr) = fcGenPV(kPredShortTArr);
    % else give warning and omit short term clear sky prediction
    else
        warning('Clear Sky Prediction incorrect, nan as result. Using original prediction.')
    end

end % end check whether clear sky energy available

end

