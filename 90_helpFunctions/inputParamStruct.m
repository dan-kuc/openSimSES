%% inputParamStruct
% Function to update struct fields with new fields.
%
% Existing param struct oldStruct with all fields is kept, while adapting
% all existing fields of inputStructs.
%
% 2017-08-22 Truong
function newStruct = inputParamStruct(oldStruct, inputStruct)

newStruct = oldStruct;
% overwriting of standard values with input parameters
nameField = fields(inputStruct);
for idxField = 1:numel(nameField)
    newStruct.(nameField{idxField}) = inputStruct.(nameField{idxField});
end
% end input param

end