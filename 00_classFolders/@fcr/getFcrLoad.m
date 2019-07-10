%% getFcrLoad
%   Sets the power for fcr usage with optimization of soc towards socSet by using degrees of freedom
%
% Update 2019-07-05 Daniel Kucevic
%%
function [ ees ] = getFcrLoad( ees )

% FCR = 1 means maximum positive discharge power to the grid
% FCR = -1 means maximum charge power from the grid to the storage

%% Assign input parameters
% Description of parameters in createFcrData
inputFcr                = ees.inputFcr;
frequencySet            = inputFcr.frequencySet;
frequencySlopeSet       = inputFcr.frequencySlopeSet;
frequencyDeadTime       = inputFcr.frequencyDeadTime;
frequencyDeadBand       = inputFcr.frequencyDeadBand;
overfulfillmentFactor   = inputFcr.overfulfillmentFactor;
simStepNow              = ees.kNow - 1;
frequencyNow            = ees.inputFcrProfiles.fcrFrequency(simStepNow);
fcrMax                  = inputFcr.fcrMax;
socOpt                  = inputFcr.socSet;
socNow                  = ees.socNow;
fcrOutNow               = ees.fcrData.fcrOutNow;

   

%% Determine FCR power with power to frequency static
fcrNet = frequencySlopeSet * (frequencyNow - frequencySet);

% Limitate requested FCR power to 100%
fcrNet = min(abs(fcrNet),1) * sign(fcrNet);

% Logging
if inputFcr.flagLogFcrResults
    ees.fcrData.fcrNet(simStepNow) = fcrNet;
end

%% Control optimal idle state of battery soc by using of degrees of freedomu
fcrOut = fcrNet;

% 1.Time flexibility (30s (frequencyDeadTime) until 100% FCR power has to be delivered)

% Determine slope: 30s (frequencyDeadTime) for 100% FCR (0-100%)
if frequencyDeadTime == 0
    frequencyDeadTime = 30;
end
frequencySlope = (fcrOut - fcrOutNow) / frequencyDeadTime;
frequencyDeadTime = frequencyDeadTime - 1;

if(socNow > socOpt && fcrOut < 0 && frequencySlope < 0)      % if SOC is higher than optimum, 
%try to charge as little as possible  
    fcrOut = max(fcrOutNow + frequencySlope, fcrOut);
elseif(socNow > socOpt && fcrOut > 0 && frequencySlope < 0)  % if SOC is higher than optimum, 
%try to discharge as much as possible
    fcrOut = max(fcrOutNow + frequencySlope, fcrOut);
elseif(socNow < socOpt && fcrOut < 0 && frequencySlope > 0) % if SOC is less than optimum, 
%try to charge as much as possible  
    fcrOut = min(fcrOutNow + frequencySlope, fcrOut);
elseif(socNow < socOpt && fcrOut > 0 && frequencySlope > 0) % if SOC is less than optimum, 
    %try to discharge as little as possible
    fcrOut = min(fcrOutNow + frequencySlope, fcrOut);
else
    frequencyDeadTime = 30;
end

ees.inputFcr.frequencyDeadTime = frequencyDeadTime;
% Save last value before using further degrees of freedom
fcrOutNow = fcrOut;

% Logging
if(ees.inputFcr.flagLogFcrResults)
    ees.fcrData.fcr30(simStepNow) = fcrOut;            
end
    
% 2.Overfulfillment until 120% (overfulfilmentFactor)

% Overfulfillment if soc < socOpt and charging necessary or the other way round   
if((socNow < socOpt) && (frequencyNow > frequencySet) || (socNow > socOpt) && (frequencyNow < frequencySet))
    if(fcrOut > 0 && socNow > socOpt)
        fcrOut = min(overfulfillmentFactor * fcrOut, 1);
    elseif(fcrOut < 0 && socNow < socOpt)
        fcrOut = max(overfulfillmentFactor * fcrOut, -1);
    end
end 

% 3.Dead band around 50 Hz with +/-10 mHz (frequencyDeadBand)
    
% Use dead band if soc > SocOpt and charging necessary
if(socNow > socOpt)      
    if(((frequencySet + frequencyDeadBand) > frequencyNow) && (frequencyNow > frequencySet))                                 
        fcrOut = 0;
    end   
% Use dead band if soc < socOpt and discharging necessary
elseif(socNow < socOpt)
    if(((frequencySet - frequencyDeadBand) < frequencyNow) && (frequencyNow < frequencySet))                                  
        fcrOut = 0;
    end
end
    
%% Calculation final fcr power after degrees of freedom
% Determine current fcr power
ees.fcrData.fcrOutNow   = fcrOutNow;        % indicator of working point in slope of FCR
ees.fcrData.fcrLoadNow  = fcrOut * fcrMax;  % actual power of system

% Logging
if(ees.inputFcr.flagLogFcrResults)
    ees.fcrData.fcrLoad(simStepNow) = ees.fcrData.fcrLoadNow;
end


end