% trigger TMS fMRI through CBU National Instruments interface.
%
% We support a very crude emulation mode (which does basically nothing) whenever the NI
% box can't be detected. This is mainly to keep experiment scripts working away from the
% NI equipment for demo/practice purposes.
%
% The first time you use this function in a session, you must initialise it
% with a special call syntax as described below. After that the call syntax
% is as in the inputs/outputs section.
%
% See also: scansync.m
%
% INITIALISATION:
% tmssync('reset');
%
% INPUTS:
% ind: array specifying which channel indices to set to 1.
%   Default [], which means that the function sends 0 on all channels to the NI card.
%   (we only have 1 channel at present so the only valid inputs are [] and 1)
%
% OUTPUTS:
% triggertime: Psychtoolbox time stamp from immediately after the NI trigger function
%   returned.
% daqstate: struct with internal state. Mainly useful for debugging.
%
% EXAMPLE:
% % initialise a session, send a 5ms trigger.
% tmssync('reset');
% % sending a 1 triggers TMS pulse
% triggertime = tmssync(1);
% WaitSecs('UntilTime', triggertime+.005);
% % notice that user must call the function again to reset the channels to 0
% offtime = tmssync();
%
% daqstate = tmssync(ind)
%
% % 2020-09-23 J Carlin, MRC CBU
function [triggertime, daqret] = tmssync(ind)

persistent daqstate


if ~exist('ind','var')
    ind = [];
end

if ischar(ind) && strcmpi(ind,'reset')
    % special case to handle re-initialising sync
    if ~isempty(daqstate)
        status = daq.ni.NIDAQmx.DAQmxClearTask(daqstate.hand);
        daq.ni.utility.throwOrWarnOnStatus(status);
    end
    daqstate = [];
    ind = [];
end


if isempty(daqstate)
    % special initialisation mode
    fprintf('initialising...\n');
    daqstate.channels = {'/dev1/port2/line7'};
    daqstate.nchannel = numel(daqstate.channels);
    daqstate.triggers = zeros([daqstate.nchannel, 1], 'uint8');
    if hasdaq()
        fprintf('initialising new scanner card transmit connection\n');
        daqstate.emulate = false;
        warning off daq:Session:onDemandOnlyChannelsAdded
        % from NI_DAQmxCreateTask
        [status, daqstate.hand] = daq.ni.NIDAQmx.DAQmxCreateTask(char(0), uint64(0));
        daq.ni.utility.throwOrWarnOnStatus(status);
        % /from NI_DAQmxCreateTask
        for this_out = daqstate.channels
            this_out_str = this_out{1};
            % from NI_DAQmxCreateDOChan
            status = daq.ni.NIDAQmx.DAQmxCreateDOChan(daqstate.hand, ...
                this_out_str,char(0), daq.ni.NIDAQmx.DAQmx_Val_ChanForAllLines);
            daq.ni.utility.throwOrWarnOnStatus(status);
            % /from NI_DAQmxCreateDOChan
        end
        % from NI_DAQmxStartTask
        status = daq.ni.NIDAQmx.DAQmxStartTask(daqstate.hand);
        daq.ni.utility.throwOrWarnOnStatus(status);
        % /from NI_DAQmxStartTask
        daqstate.sendfun = @sendtrigger_lowlevel;
    else
        fprintf('NI CARD NOT AVAILABLE - entering trigger emulation mode\n')
        fprintf('if you see this message in the scanner, DO NOT PROCEED\n')
        daqstate.emulate = true;
        % dummy 
        daqstate.hand.release = @(x)fprintf('reset scansync session.\n');
        daqstate.sendfun = @sendtrigger_emulate;
    end
    % all setup done
    % we continue to the main block below, which has the effect of setting all channels
    % to 0.
end

% if we make it here, it's trigger time
% recode indices to column vector
% matlab is fun
assert(all(ind <= daqstate.nchannel), 'index out of range');
triggers = daqstate.triggers;
triggers(ind) = 1;
triggertime = daqstate.sendfun(daqstate, triggers);

if nargout > 1
    daqret = daqstate;
end

function triggertime = sendtrigger_lowlevel(daqstate, triggers)

% from NI_DAQmxWriteDigitalLines
[status, ~, ~] = daq.ni.NIDAQmx.DAQmxWriteDigitalLines(daqstate.hand, ...
    int32(1), uint32(false), double(10), ...
    uint32(daq.ni.NIDAQmx.DAQmx_Val_GroupByChannel), ...
    triggers, int32(0), uint32(0));
triggertime = GetSecs;
daq.ni.utility.throwOrWarnOnStatus(status);
% /from NI_DAQmxWriteDigitalLines

function triggertime = sendtrigger_emulate(daqstate, triggers)

% empty for now
triggertime = GetSecs;
