%% calcBatterySize
%
% calcBatterySize calculates the size of the storage unite arccording to the
% load profile end the maximum amount of power the grid shoulr offer
%
% Matthias Mayer, 13.03.2018

function [ eBattNom ] = calcBatterySize( loadprofile, power2gridcax, tSample )
% sample time relativ umsonst (Intresannter ist hier die Profilart) dann
% kannst du unten die batterynominalenergy allgemein berechnen
netLoad         = loadprofile;  % copy load profile

for a = 1:size(loadprofile)             % when the current load is bigger than the maximum grid load the data point gets reduced to the maximum grid power value
    if (netLoad(a) > power2gridcax)    
        netLoad(a) = power2gridcax;
     
    else 
        netLoad(a) = loadprofile(a);
    end
end
 %% Calculate amount of energy 
 eLoad = sum(loadprofile) * tSample; % [Wmin] energy amount of the load profile
 % use Integralfunction?
 eGrid = sum(netLoad) * tSample; % [Wmin] energy amount the grid delivers
 eBatt = eLoad - eGrid; % [Wmin] necessary energy ammount of the storage *60[s/min]
 
 %% write into outputarg
 
 eBattNom = eBatt * 1.1; % [Ws] increase the battery size by 10%
 % agins, selfdischarge...
 

end

