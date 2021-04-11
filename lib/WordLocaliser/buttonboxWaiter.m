% works with scansync to wait for buttonbox presses for some duration
%
% requires
%   - scansync
%   - duration
%
% produces
%   - an rt for the first trigger (button press)
%   - the trigger number of first button pressed
%   - a number and rt for all buttons pressed
%
% you should specify what scansync triggers you care about (here I get 2:5)
function [rt, firstPressed, allPressed] = buttonboxWaiter(duration)

scansyncTriggersWeCareAbout = 2:5;

persistent lastresp
if isempty(lastresp) % initialise for first use
    lastresp = NaN(length(scansyncTriggersWeCareAbout));
end

timeNow = GetSecs;

[~,~,out] = scansync([],timeNow+duration);

% get the value of the lastresp variable from scansync
thisresp = out.lastresp(scansyncTriggersWeCareAbout);

if any(thisresp)
    if isequaln(lastresp,thisresp) % is equal, but with nans
        % if no change this resp to last resp
        allPressed = 0;
        firstPressed = 0; % code invalid response
        rt = NaN;
    else
        % else figure out what triggers are different
        tmp1=thisresp;
        tmp2=lastresp;
        % deal with the bloody NaNs
        tmp1(isnan(thisresp)) = 0;
        tmp2(isnan(lastresp)) = 0;
        allPressed = find(tmp1 ~= tmp2); % get the differences
        for iresult = 1:length(allPressed)
            % get the times
            allPressed(2,iresult) = tmp1(allPressed(1,iresult))-timeNow;
        end
        % get the first difference by time
        first_press = allPressed(1,find(allPressed(2,:) == min(allPressed(2,:))));
        % get the trigger number of the first different trigger
        firstPressed = first_press;
        % get the rt of the first different trigger
        rt = min(allPressed(2,:)); clear tmp1 tmp2;
    end
else % if there is no valid value in thisresp (i.e. all NaNs)
    allPressed = 0;
    firstPressed = 0; % code invalid response
    rt = NaN;
end

lastresp = thisresp; % update

end