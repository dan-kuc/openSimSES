%% 1.3 +++ getTechnoEconomicInput() 
%
% getTechnoEconomicInput() reads input from excel input file and allocates 
% the specified variables to input structs
%
% These structs are:
%   - inputTech
%   - inputEconomics
%
% inputSim is handled separately in getGeneralInput()
%
% Depending on the chosen scenario, the following structs are created
% additionally:
%   - inputFcr
%
% INPUT
%   filename    name of excel file that contains all parameters (must be in path)
%   scenario    application of storage e.g. buffer storage, residential, fcr...
%
% OUTPUT
%   inputTech           technical input parameters
%   inputEconomics      economic input parameters
%   inputFcr (optional) parameters specifically for fcr application
% 
%   2019-07-05 Daniel Kucevic
%%

function [inputTech, inputEconomics, varargout] = getTechnoEconomicInput(filename, scenario)

% Specify ranges of data in Excel sheets
rangeTechSheet      = 'A1:C52';
rangeEconSheet      = 'A1:C10';

% Handle the second sheet (inputTech)
[~,~,inputTechSheetRaw] = xlsread(filename, 2, rangeTechSheet);

if strcmp(scenario, 'fcr')
    [inputTech, inputFcr] = allocateTechSheet(inputTechSheetRaw, scenario); 
    varargout{1}          = inputFcr; 
else
    inputTech = allocateTechSheet(inputTechSheetRaw, scenario); 
end

% Handle the third sheet (inputEconomics)
[~,~,inputEconomicsSheetRaw]    = xlsread(filename, 3, rangeEconSheet);
[inputEconomics]                = allocateEconomicsSheet(inputEconomicsSheetRaw, scenario); 

end
