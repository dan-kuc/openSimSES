%% resetState method
% Method resets state of storage object to previous simulation step.
% Iterative evaluation of operation is now possible, starting with
% determined state.
%
%   Call:   resetState( ees, step )
%   ees:    object
%   step:   starting step of new iteration. Object is reset to state of
%           previous step.
%
% Truong

function [ ees ] = resetState( ees, step )
% step to be reverted to
rStep       = step - 1;
kNow        = max(step,1);
ees.kNow    = kNow;
ees.tNow    = kNow * ees.inputSim.tSample;

% if object is reset to beginning state of timeRange
if rStep < 1
    ees.socNow          = ees.inputTech.soc0;
    ees.sohCapNow       = ees.inputTech.sohCap0;        
    ees.sohResNow       = ees.inputTech.sohRes0;
% otherwise just use state of previous step
else
    ees.socNow          = ees.soc(rStep);
    ees.sohCapNow       = ees.sohCap(rStep);        
    ees.sohCap(step)    = ees.sohCap(rStep);
    ees.sohResNow       = ees.sohRes(rStep);
    ees.sohRes(step)    = ees.sohRes(rStep);
end % end if

end % end fct

