%% noAging function
% 
% Script to define function for an aging model functions (calAgingFct, cycAgingFct and combAgingFct)
% No aging is computed. Saves computation time.
% Purpose is to temporarily swap aging within OS that require
% predictive simulation of time periods. (See
% OSDynamicFeedInLimitSmartGuessNT for example-use)
%
% Function owner: Nam Truong
% Creation date: 10.03.2016
%
%%
function aging = noAgingFct( varargin )

aging.relCapacityChange    = 0;
aging.relResistanceChange  = 0;

end
