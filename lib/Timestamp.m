function ts = Timestamp(description, initTime, trialNum)
% print info to outfile
% TO DO: SCANNER SYNC - want time, pulse number estimate, last real pulse
% etc with high priority
% For now: just print Trial number, trial type, description, time since
% script initialised
ts = struct();

%catch missing variables
if nargin < 3; trialNum = 0; end

ts.description = description;
ts.inittime = initTime;
ts.time = 1000*(GetSecs() - initTime);
ts.trial_number = trialNum;

end
