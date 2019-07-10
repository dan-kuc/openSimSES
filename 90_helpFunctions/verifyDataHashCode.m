%%  verifyDataHashCode
%
% Checks if hash tag for data input is correct. Function is called in
% returnInputProfile, if hash checking is activated.
%
% Input: 
% - Data [-]: Array of these built-in types:
%   (U)INT8/16/32/64, SINGLE, DOUBLE, (real/complex, full/sparse)
%   CHAR, LOGICAL, CELL (nested), STRUCT (scalar or array, nested),
%   function_handle.
% - hashCode [-]: String, DOUBLE or UINT8 vector. The length depends on the 
%   hashing method.
% - profileFileName [-]: String with name of profile which is checked
%
% Output: None -> Only message in console
%
% This functions calls the verifyDataHashCode function and compares the
% calculated hash code with the given hash code. If the hash codes match
% each other, the file was not manipulated. If they do not match, some kind
% of manipulation happend. For each case a console message is displayed.
%
% 2017-08-04   Maik Naumann
%
%%

function verifyDataHashCode(data, hashCode, profileFileName)
if ~(strcmp(returnDataHashCode(data), hashCode))
  error([profileFileName,': Hash code not correct -> File is manipulated!']);
else
  disp([profileFileName,': Hash code correct -> File is not manipulated']);  
end