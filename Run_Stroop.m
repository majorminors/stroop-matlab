%% Stroop task
% Dorian Minors
% Created: JAN21
% Last Edit: JAN21
%% set up

close all;
clearvars;
clc;

fprintf('setting up %s\n', mfilename);
p = struct(); % est structure for parameter values
d = struct(); % est structure for trial data
t = struct(); % another structure for untidy trial specific floating variables that we might want to interrogate later if we mess up

% initial settings
rootdir = pwd; % root directory - used to inform directory mappings
p.vocal_stroop = 0;
p.manual_stroop = 1;
p.testing_enabled = 0; % change to 0 if not testing (1 skips PTB synctests) - see '% test variables' below
p.fullscreen_enabled = 0;
p.skip_synctests = 0; % skip ptb synctests
p.screen_num = 0;
p.colours = {'red','blue','green'}; % used to create response coding, will assume stimulus file is named with correct colours
p.sizes = {'short','medium','tall'}; % used to create response coding
p.screen_width = 40;   % Screen width in cm
p.screen_height = 30;    % Screen height in cm
p.screen_distance = 50; % Screen distance from participant in cm

if p.vocal_stroop && p.manual_stroop; error('you have selected both vocal and manual stroop!'); end

% directory mapping
if ispc; setenv('PATH',[getenv('PATH') ';C:\Program Files\MATLAB\R2018a\toolbox\CBSU\Psychtoolbox\3.0.14\PsychContributed\x64']); end % make sure psychtoolbox has all it's stuff on pc
addpath(genpath(fullfile(rootdir, 'lib'))); % add tools folder to path (includes moving_dots function which is required for dot motion, as well as an external copy of subfunctions for backwards compatibility with MATLAB)
stimdir = fullfile(rootdir, 'lib', 'stimuli');
datadir = fullfile(rootdir, 'data'); % will make a data directory if none exists
if ~exist(datadir,'dir'); mkdir(datadir); end

% test variables
if p.testing_enabled == 1
    p.PTBsynctests = 1; % PTB will skip synctests if 1
    p.PTBverbosity = 1; % PTB will only display critical warnings with 1
    Screen('Preference', 'ConserveVRAM', 64); % for working on a vm, we need this enabled
elseif p.testing_enabled == 0
    if p.skip_synctests
        p.PTBsynctests = 1;
    elseif ~p.skip_synctests
        p.PTBsynctests = 0;
    end
    p.PTBverbosity = 3; % default verbosity for PTB
end
Screen('Preference', 'SkipSyncTests', p.PTBsynctests);
Screen('Preference', 'Verbosity', p.PTBverbosity);

% psychtoolbox setup
AssertOpenGL; % check Psychtoolbox (on OpenGL) and Screen() is working
KbName('UnifyKeyNames'); % makes key mappings compatible (mac/win)
rng('shuffle'); % seed rng using date and time

% set up participant info and save
t.prompt = {'enter participant number:'};%,... % prompt a dialog to enter subject info
t.prompt_defaultans = {num2str(99)}; % default answers corresponding to prompts
t.prompt_rsp = inputdlg(t.prompt, 'enter participant info', 1, t.prompt_defaultans); % save dialog responses
d.participant_id = str2double(t.prompt_rsp{1}); % add subject number to 'd'

% check participant info has been entered correctly for the script
if isnan(d.participant_id); error('no participant number entered'); end

% create a save file
if p.vocal_stroop; t.exp_type = 'vocal'; elseif p.manual_stroop; t.exp_type = 'manual'; end
save_file_name = [num2str(d.participant_id,'S%02d'),'_',t.exp_type,'_',mfilename];
save_file = fullfile(datadir, save_file_name);
if exist([save_file '.mat'],'file') % check if the file already exists and throw a warning if it does
    warning('the following save file already exists - overwrite? (y/n)\n %s.mat', save_file);
    while 1 % loop forever until y or n
        ListenChar(2);
        [secs,keyCode] = KbWait; % wait for response
        key_name = KbName(keyCode); % find out name of key that was pressed
        if strcmp(key_name, 'y')
            fprintf('instructed to overwrite:\n %s.mat\n overwriting and continuing with %s\n', save_file, mfilename)
            ListenChar(0);
            clear secs keyCode key_name
            break % break the loop and continue
        elseif strcmp(key_name, 'n')
            ListenChar(0);
            clear secs keyCode key_name
            error('instructed not to overwrite:\n %s.mat\n aborting %s\n', save_file, mfilename); % error out
        end
    end % end response loop
end % end check save file exist
save(save_file); % save all data to a .mat file

%% define experiment parameters

fprintf('defining exp params for %s\n', mfilename);
