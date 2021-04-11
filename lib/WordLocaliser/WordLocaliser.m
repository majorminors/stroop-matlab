%% VWFA Localiser
% Dorian Minors
% Created: APR21
% Last Edit: APR21
% heavily borrowed from Peter Scarfe tutorials
%% set up

close all;
clearvars;
clc;

fprintf('setting up %s\n', mfilename);
p = struct(); % est structure for parameter values
d = struct(); % est structure for trial data
t = struct(); % another structure for untidy temp floating variables

rootdir = pwd;

p.testing_enabled = 1;

p.tests = {'falsefonts','words','pseudowords','faces','houses','objects'};

% set for values when testing not enabled (you need to change testing
% defaults independently
p.fullscreen_enabled = 1;
p.skip_synctests = 0;
p.scanning = 1;
p.buttonbox = 1;
p.window_size = [0 0 1200 800]; % size of window when ~p.fullscreen_enabled

% --- dir mapping --- %

addpath(genpath(fullfile(rootdir, 'lib'))); % add tools folder to path
stimdir = fullfile(rootdir, 'stimuli');
datadir = fullfile(rootdir, 'data'); % will make a data directory if none exists
if ~exist(datadir,'dir'); mkdir(datadir); end

% % pull in stimuli locations
% t.extension = '.jpg';
% t.dir_info = dir(['*' t.extension]);
% t.fileNames = {t.dir_info.name};
% t.stimuli = cell(numel(t.fileNames),2);
% t.stimuli(:,1) = regexprep(t.fileNames, t.extension,'');
% %don't think we need this - think we have the ability to do location now
% %with fullfile(stimdir,t.stimuli(n))
% % for ii = 1:numel(t.fileNames)
% %    t.stimuli{ii,2} = dlmread(t.fileNames{ii});
% % end

% --- PTB and defaults --- %

AssertOpenGL; % check Psychtoolbox (on OpenGL) and Screen() is working
KbName('UnifyKeyNames'); % makes key mappings compatible (mac/win)
rng('shuffle'); % seed rng using date and time

%-------------------------------%
% defaults and testing settings %
%-------------------------------%

if p.testing_enabled == 1
    p.PTBsynctests = 1; % PTB will skip synctests if 1
    p.PTBverbosity = 1; % PTB will only display critical warnings with 1
    p.fullscreen_enabled = 0;
    p.scanning = 0;
    p.buttonbox = 0;
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
% PsychDefaultSetup(2);

% --- screen stuff --- %

% Get the screen numbers
p.screens = Screen('Screens');

% Draw to the external screen if avaliable
p.screenNumber = max(p.screens);

% Define p.black and p.white
p.white = WhiteIndex(p.screenNumber);
p.black = BlackIndex(p.screenNumber);
p.grey = p.white / 2;
inc = p.white - p.grey;

% --- set up participant id and create a save file --- %

t.prompt = {'enter participant number:'}; % prompt a dialog to enter subject info
t.prompt_defaultans = {num2str(99)}; % default answers corresponding to prompts
t.prompt_rsp = inputdlg(t.prompt, 'enter participant info', 1, t.prompt_defaultans); % save dialog responses
d.participant_id = str2double(t.prompt_rsp{1}); % add subject number to 'd'
% check participant info has been entered correctly for the script
if isnan(d.participant_id); error('no participant number entered'); end

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


%% begin

try
    if p.fullscreen_enabled % zero out p.window_size if p.fullscreen_enabled = 1
        p.window_size=[];
    end
    % Open an on screen window
    [p.window, p.windowRect] = PsychImaging('OpenWindow', p.screenNumber, p.grey, p.window_size);
    
    % Get the size of the on screen window
    [p.screenXpixels, p.screenYpixels] = Screen('WindowSize', p.window);
    
    
    % Query the frame duration
    p.ifi = Screen('GetFlipInterval', p.window);
    
    % Get the centre coordinate of the window
    [p.xCenter, p.yCenter] = RectCenter(p.windowRect);
    
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', p.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % instructions
    showText(p,'TASK: PRESS A BUTTON IF YOU SEE\nTHE SAME THING TWICE IN A ROW');
    WaitSecs(1); % so you hopefully don't have keys down!
    if p.buttonbox
        scansync([2:5],Inf); % wait for any button trigger to be pressed and return
    else
        KbWait(); % wait for a button press
    end
    
    % for task, show a bunch of stimuli in random order, press a button to
    % determine if stimuli repeated
    % code if a repeat
    % code if successfully detected
    % code if erroneously labelled a repeat
    
    %     showImage(p,imageLocation);
    %     showText(p,textToShow);
    
    %%Break out of Loop if need to with keyboardbutton 'q'
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    if keyIsDown;
        if strcmp(KbName(keyCode),'q');
            Screen('CloseAll');
            return
        end
    end
    
    % Wait for two seconds
%     WaitSecs(2);
    
    % Clear the screen
    sca;
    
catch err
    save(save_file);
    ShowCursor;
    Screen('CloseAll');
    rethrow(err);
end
