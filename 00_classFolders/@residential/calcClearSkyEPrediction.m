%% calcClearSkyEPrediction
% Calculates the clear sky prediction of a photovoltaic unit based on the 
% energy generated already. 
%
% timeNow, lookAhead periode, actual profile of the day, forecast profile
% == Input
% ees           [-] storage object
% tLookAhead    [s] 2 values: starting and endpoint of lookahead period
%
function fcGenPV = calcClearSkyEPrediction(ees, kLookAhead)
% Helping variables
global gvarKWH2WS gvarDAYS2SECONDS gvarYEARS2SECONDS

inputTech       = ees.inputTech;
pPVnom          = inputTech.pPVnom;
tSample         = ees.inputSim.tSample;                         % tSample
nStepsSim       = length(ees.SOC);
kPerDay         = gvarDAYS2SECONDS / tSample;
kNow            = kLookAhead(1);

[kOfDay,dayNow] = step_2_step_of_day(kNow, kPerDay);    % k of current day and # of current day
kLookAhead(end) = min(kLookAhead(end), nStepsSim);        % keep lookahead within limits
% nDaysLookAhead  = (diff(kLookAhead) + 1) .* tSample / gvarDAYS2SECONDS;    % # of days

% generate indexing array for all days within look ahead period
k0DayNow        = (dayNow-1) * kPerDay + 1;                 % first step of current day
% kProfileArray   = k0DayNow + (1:kPerDay*ceil(nDaysLookAhead));
kProfileArray   = kLookAhead(1):kLookAhead(end);
fcGenPV         = ees.inputForecast.genPV(kProfileArray);                      

% workaround for simulation of only 30 days --> starting at day 101
if nStepsSim < gvarYEARS2SECONDS/tSample          
    dayNow = dayNow + 100;
end

% [pu] clear sky profile of current day
rClSky      = gen_clear_sky_pv( ...
                dayNow,                    ...
                kPerDay,                    ...
                inputTech.paramPVdegLat,    ...
                inputTech.paramPVangleIncl, ...
                inputTech.paramPVangleAzim  );              

%% current time step be used for clear sky short term prediction
if rClSky(max(kOfDay-1, 1)) > 0
    % calculate indexing of arrays
    lPredShortT 	= round(inputTech.genPredTShortTerm / tSample); % # of k for short term prediction interval
    kPredShortTArr  = kOfDay-1 + (1:lPredShortT);                     % index array for short term pred interval
    % estimate prediction rate from clear sky.
    pGenReal        = ees.inputProfiles.genPV(k0DayNow:(kNow-1));   % generation from start of day until now
    pClSky          = rClSky * pPVnom;                              % [W]  clear sky generation of current day
    eGenReal        = sum(pGenReal)             * tSample;          % generated energy from start of day until now
    eGenClSky       = sum(pClSky(1:(kOfDay-1))) * tSample;          % clear sky generated energy from start of day until now
    rGenPred        = eGenReal / eGenClSky;                         % ratio of actually generated energy vs clear sky potential
    pPredClSky      = rGenPred * pClSky;                            % generate according clear sky generation

    % only calculate clear sky if nan is not an issue
    if ~isnan(rGenPred)
% % %         % correct prediction, if overestimated --> limit to PVpeak
% % %         rPredMax =  max(pPredClSky) / pPVnom;
% % %         if rPredMax > 1
% % %             pPredClSky = pPredClSky / rPredMax;
% % %         end
        % replace original prediction with clear sky short term prediction
%         plot(kProfileArray, fcGenPV)
%         hold on
        fcGenPV(1:lPredShortT) = pPredClSky(kPredShortTArr);    

    % else give warning and omit short term clear sky prediction
    else
        warning('Clear Sky Prediction incorrect, nan as result. Using original prediction.')
    end

end % end check whether clear sky energy available

% plot(k0DayNow+(1:kPerDay),pClSky), plot(k0DayNow:kLookAhead(2),ees.inputProfiles.genPV(k0DayNow:kLookAhead(2))),  plot(k0DayNow-1+kPredShortTArr, pPredClSky(kPredShortTArr)), plot(kProfileArray, fcGenPV)

end

