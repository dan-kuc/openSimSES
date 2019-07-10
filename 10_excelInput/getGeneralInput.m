%% 1.2 +++ getGeneralInput()
%
% getGeneralInput gets the input specified in the first sheet of
% inputParameters.xlsx and allocates it to input struct inputSim
%
% INPUT
%   filename    Input Excel file name, string
%
% OUTPUT
%   inputSim    Input struct containing simulation parameters
%
%   2019-07-05 Daniel Kucevic
%%
function [inputSim] = getGeneralInput(filename)
rangeStartSheet             = 'A4:F10'; % Determine the range in which data is stored in excel sheet
[~,~,inputStartSheetRaw]    = xlsread(filename, 1, rangeStartSheet); % Read data and store it in cells cause it is numeric and text data
[inputSim]                  = allocateStartSheet(inputStartSheetRaw); % Allocate it to input struct inputSims
end
