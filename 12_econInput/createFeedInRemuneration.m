%% createFeedInRemuneration
% Function that generates scenarios of feed in remuneration, using the selected
% method. 
%
% structEconomics = createFeedInRemuneration( structEconomics )
%
% Input == (parameters)
% structEconomics   struct with input economic parameters
%
% Output ==
% structEconomics   struct with input economic parameters including field
%                   with feed in remuneration
%
% Function to call just before object instantiation. Main simulation script
% for residential calls 'createEconParamPVHomeStorage', where this function
% is invoked.
%
% 2017-10-10 Nam Truong
% 
%%

function [ structEconomics ] = createFeedInRemuneration( structEconomics )

%% switch case for choosen feed in remuneration scenario
switch lower(structEconomics.pvHome.scenarioFeedInRemuneration)
    
    % fixed feed in remuneration rate for whole depreciation period
    case('constant')    
        structEconomics.pvHome.feedInRemuneration = repmat(structEconomics.pvHome.feedInRemuneration, structEconomics.general.depreciationPeriod, 1);
        
    % fixed feed in remuneration rate for whole depreciation period
    % starting 2018
    case 'constant q1 18'
        structEconomics.pvHome.feedInRemuneration = repmat(0.122, structEconomics.general.depreciationPeriod, 1);
        
    % no guaranteed remuneration but avg. market price 2017 base (http://www.bricklebrit.com/stromboerse_leipzig.html)
    case 'constant market'
        structEconomics.pvHome.feedInRemuneration = repmat(0.03, structEconomics.general.depreciationPeriod, 1);
        
    otherwise
        disp('Chosen scenario does not exist.');
        
end
%% Display chosen scenario in command window
disp([mfilename('fullpath') ':'])
disp(['<strong> Feed-in remuneration scenario: ', structEconomics.pvHome.scenarioFeedInRemuneration, '</strong>'])


end