%% Matching motion coherence to direction cue in MEG
% Dorian Minors
% Created: JUN19
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
p.testing_enabled = 0; % change to 0 if not testing (1 skips PTB synctests and sets number of trials and blocks to test values) - see '% test variables' below
p.fullscreen_enabled = 0;
p.skip_synctests = 0; % skip ptb synctests

% directory mapping
addpath(genpath(fullfile(rootdir, 'lib'))); % add tools folder to path (includes moving_dots function which is required for dot motion, as well as an external copy of subfunctions for backwards compatibility with MATLAB)
stimdir = fullfile(rootdir, 'lib', 'stimuli');
datadir = fullfile(rootdir, 'data'); % will make a data directory if none exists
if ~exist(datadir,'dir')
    mkdir(datadir);
end

% test variables
if p.testing_enabled == 1
    p.PTBsynctests = 1; % PTB will skip synctests ifimread(fullfile(stimdir, 1
    p.PTBverbosity = 1; % PTB will only display critical warnings with 1
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
if isnan(d.participant_id)
    error('no participant number entered');
end

% create a save file
save_file_name = [num2str(d.participant_id,'S%02d'),'_',mfilename];
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

% define keys
p.resp_keys = {'1','2','3'}; % only accepts three response options
p.resp_coding.short = p.resp_keys{1};
p.resp_coding.medium = p.resp_keys{2};
p.resp_coding.tall = p.resp_keys{3};
p.resp_coding.red = p.resp_keys{1};
p.resp_coding.blue = p.resp_keys{2};
p.resp_coding.green = p.resp_keys{3};
p.quitkey = {'q'};

% define display info
p.bg_colour = [0 0 0];
p.text_colour = [255 255 255]; % colour of instructional text
p.text_size = 40; % size of text
p.window_size = [0 0 1200 800]; % size of window when ~p.fullscreen_enabled
p.visual_angle = 10; % visual angle of the stimulus expressed as a decimal - determines size

% timing info
p.iti_time = 0.3; % inter trial inteval time
p.trial_duration = 1.5; % seconds for the stimuli to be displayed
p.feedback_time = 0.5; % period to display feedback after response
p.min_stim_time = 0.2; % time to not show the stimulus
% lets check all those parameters
t.view_p = struct2table(p, 'AsArray', true);
disp(t.view_p);
warning('happy with all this? (y/n)\n %s.mat', save_file);
while 1 % loop forever until y or n
    ListenChar(2);
    [secs,keyCode] = KbWait; % wait for response
    key_name = KbName(keyCode); % find out name of key that was pressed
    if strcmp(key_name, 'y')
        fprintf('happy with parameters\n continuing with %s\n', mfilename)
        ListenChar(0);
        clear secs keyCode key_name
        break % break the loop and continue
    elseif strcmp(key_name, 'n')
        ListenChar(0);
        clear secs keyCode key_name
        error('not happy with parameters\n aborting %s\n', mfilename); % error out
    end
end % end response loop

%% define stimuli parameters

fprintf('defining stimuli params for %s\n', mfilename);

t.colours = ['red','blue','green'];

% read in stimuli files for the cue
t.stimuli = dir(fullfile(stimdir,'*.svg'));
for i = 1:numel(t.stimuli)
    t.filename = t.stimuli(1).name;
    p.stimuli{i,1} = imread(fullfile(stimdir, t.filename));
    p.stimuli{i,2} = erase(t.filename,'.svg');
end

%% exp start

fprintf('running experiment %s\n', mfilename);

try
    % open screen
    if p.fullscreen_enabled % zero out p.window_size if p.fullscreen_enabled = 1
        p.window_size=[];
    end
    [p.win,p.rect] = Screen('OpenWindow',p.screen_num,p.bg_colour,p.window_size);
    %Screen('BlendFunction',p.win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); % allows transparency in .png images
    Screen('TextSize', p.win, p.text_size); % set the text size
    % then need some info based on the screen for later
    %p.frame_rate = 1/Screen('GetFlipInterval', p.win); % is Hz
    %p.resolution = p.rect([3,4]); % pull resolution info from p.rect - used to scale cue image and is passed to moving_dots to do the same
    HideCursor;
    WaitSecs(0.5); % warm up
    
    %% start trial
    % will want a trial loop, can report trial with something like:
    % fprintf('trial %u of %u\n',i,p.trial_num); % report trial number to command window
    
    % set up a queue to collect response info
    t.queuekeys = [KbName(p.resp_keys{1}), KbName(p.resp_keys{2}), KbName(p.quitkey)]; % define the keys the queue cares about
    t.queuekeylist = zeros(1,256); % create a list of all possible keys (all 'turned off' i.e. zeroes)
    t.queuekeylist(t.queuekeys) = 1; % 'turn on' the keys we care about in the list (make them ones)
    KbQueueCreate([], t.queuekeylist); % initialises queue to collect response information from the list we made (not listening for response yet)
    KbQueueStart(); % starts delivering keypress info to the queue
    
    % make the texture and scale it
    t.stim_tex = Screen('MakeTexture', p.win, t.stimulus);
    [t.tex_size1, t.tex_size2, t.tex_size3] = size(t.stim_tex); % get size of texture
    t.aspectratio = t.tex_size2/t.tex_size1; % get the aspect ratio of the image for scaling purposes
    t.imageheight = angle2pix(p,p.visual_angle); % scale the height of the image using the desired visual angle
    t.imagewidth = t.imageheight .* t.aspectratio; % get the scaled width, constrained by the aspect ratio of the image

    % parameterise the rect to display cue in
    t.imgrect = [0 0 t.imagewidth t.imageheight]; % make a scaled rect for the cue
    t.rect = CenterRectOnPointd(t.imgrect,p.resolution(1,1)/2,p.resolution(1,2)/2); % offset it for the centre of the window

    % iti
    % might need some screen flipping here to go blank?
    WaitSecs(p.iti_time)
    
    % then display cue
    Screen('DrawTexture', p.win, t.stim_tex, [], t.rect); % draws the cue
    d.cue_onset = Screen('Flip', p.win); % pull the time of the screen flip from the flip function while flipping
    WaitSecs(p.min_stim_time); % going to need to stop responding in this time, or code as zero
    Screen('DrawTexture', p.win, t.stim_tex, [], t.rect); % redraws the cue
    Screen('Flip', p.win);
    WaitSecs(p.trial_duration); % wait for trial    

    %% deal with response

    % deal with keypress
    [t.pressed,t.firstPress] = KbQueueCheck(); % check for keypress in the KbQueue
    d.resp_key_name{block,i} = KbName(t.firstPress); % get the name of the key used to respond - needs to be squiggly brackets or it wont work for no response
    d.resp_key_time(block,i) = sum(t.firstPress); % get the timing info of the key used to respond
    d.rt(block,i) = d.resp_key_time(block,i) - d.dots_onset(block,i); % rt is the timing of key info - time of dots onset (if you get minus values something's wrong with how we deal with nil/early responses)
    
    % save the response key (as a code)
    if cell2mat(d.resp_key_name(block,i)) == p.resp_keys{1}
        d.resp_keycode(block,i) = 1; % code response 1 pressed
    elseif cell2mat(d.resp_key_name(block,i)) == p.resp_keys{2}
        d.resp_keycode(block,i) = 2; % code response 2 pressed
    else
        d.resp_keycode(block,i) = 0; % code invalid response
    end
    
    % score and create feedback variable e.g.
                % score response
%             if strcmp(d.resp_key_name(block,i), d.correct_resp(block,i))
%                 d.correct(block,i) = 1; %correct trial
%                 t.feedback = 'correct';
%             elseif strcmp(d.resp_key_name(block,i), d.incorrect_resp(block,i))
%                 d.correct(block,i) = 0; %incorrect trial
%                 t.feedback = 'incorrect';
%             elseif strcmp(d.resp_key_name(block,i),p.quitkey)
%                 fclose('all');
%                 error('%s quit by user (p.quitkey pressed)\n', mfilename);
%             else
%                 d.correct(block,i) = -1; % nil response
%                 d.rt(block,i) = 0;
%                 t.feedback = 'no valid input';
%             end % end check correct
    
    % display some feedback if trialwise feedback on
    if p.feedback_type == 1
        DrawFormattedText(p.win, t.feedback, 'center', 'center', p.text_colour); %display feedback
        Screen('Flip', p.win);
        WaitSecs(p.feedback_time);
        Screen('Flip', p.win);
    end
    
    %% post trial cleanup
    KbQueueRelease();
    
    % end trial here
    
    %% wrap up
    
    % tell them it's over
    DrawFormattedText(p.win,'done!', 'center', 'center', p.text_colour); % tell them it's over!
    Screen('Flip', p.win);
    WaitSecs(1);
    Screen('Flip', p.win);
    
    % close screen
    ShowCursor;
    KbQueueRelease(); %KbReleaseWait();
    if p.MEG_enabled == 1; MEG.delete; end % stop MEG from limiting button presses
    clear block i ans; % clear specific indexes and stuff
    Screen('Close',p.win);
       
    fprintf('done running %s\n', mfilename);
    
catch err
    save(save_file);
    ShowCursor;
    sca; %Screen('Close',p.win);
    rethrow(err);
end
