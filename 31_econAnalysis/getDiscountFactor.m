%% getDiscountFactor
% Calculates the discount factor based on depreciation period and interest
% rate.
% 3rd input is optional inflation rate.
% 
% === Input 
% tDepreciation [years]
% rInterest     [pu]
% (rInflation)  [pu]
%
% === Output
% discountFactor [-] array
% rInterestReal  [pu] real interet rate
%
% 2018-08-08 Truong


function [discountFactor, rInterestReal] = getDiscountFactor(tDepreciation, rInterest, varargin)

if nargin > 2
    rInterestReal = (1 + rInterest) / (1 + varargin{1}) - 1;
else
    rInterestReal = rInterest;
end

interestFactor  = 1 + rInterestReal;
discountFactor  = interestFactor.^-(1:tDepreciation).';

end

