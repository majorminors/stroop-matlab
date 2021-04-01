function ts = Timestamp(description, initTime, proc, trialNum)
% print info to outfile
% TO DO: SCANNER SYNC - want time, pulse number estimate, last real pulse
% etc with high priority
% For now: just print Trial number, trial type, description, time since
% script initialised
ts = struct();

%catch missing variables
if nargin < 2; 
if nargin < 3; proc = 0; end
if nargin < 4; trialNum = 0; end

ts.description = description;
ts.time = 1000*(GetSecs() - initTime);
ts.procedure = proc;
ts.trial_number = trialNum;

end