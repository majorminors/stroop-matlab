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

% this script will loop through the first row of test info, then do a
% switch operation, I'm using the second row to feed it the information it
% needs
p.testInfo = ...
    {'words','pseudowords','falsefonts';...
    'words.txt','pseudowords.txt','falsefonts.txt'};

% set for values when testing not enabled (you need to change testing
% defaults independently
p.fullscreen_enabled = 1;
p.skip_synctests = 0;
p.scanning = 1;
p.buttonbox = 1;
p.window_size = [0 0 1200 800]; % size of window when ~p.fullscreen_enabled

p.numBlocks = 2;
p.testTime = 16;
p.stimTime = 0.5;
p.itiTime = 0.1;
p.numTrials = floor(p.testTime/(p.stimTime+p.itiTime));
p.numRepeats = 3; % number of repeats to have in a trial (note: we use this to divide trials into segments, and put a repeat in each segment)

p.resp_keys = {'1!','2@','3#'}; % only accepts three response options
p.quitkey = {'q'};

% --- dir mapping --- %

addpath(genpath('C:\Users\dorian\Downloads\02-dev\stroop-matlab\lib'));
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
    
    for block = 1:p.numBlocks
        
        %%------------------------------------%%
        %% shuffle test order and begin tests %%
        %%------------------------------------%%
        tmp = Shuffle(p.testInfo,[1]); % shuffle testInfo cols (keep rows)
        t.tests = tmp(1,:); clear tmp % pull the tests into a temp variable
        
        for test = 1:length(t.tests)
            t.trialType = t.tests{test};
            
            % --- what are we doing for each test here? --- %
            switch t.trialType
                case p.testInfo{1,1}
                    t.stimuli = makeWordList(p.testInfo{2,1}); % make a word list from the file specified in the second row of the corresponding testinfo column
                case p.testInfo{1,2}
                    t.stimuli = makeWordList(p.testInfo{2,2}); % make a word list from the file specified in the second row of the corresponding testinfo column
                case p.testInfo{1,3}
                    t.stimuli = makeWordList(p.testInfo{2,2});
                    % make this false fonts and do something different here I
                    % think
            end
            
            % --- randomise the trial order and generate repeats --- %
            t.randomisedOrder = zeros(1,p.numTrials); % init this with all same values
            while length(unique(t.randomisedOrder)) ~= p.numTrials % let's make these all unique - repeats are hard to deal with in code and might be confusing at edge cases for participants
                t.randomisedOrder = randi(length(t.stimuli),p.numTrials,1);
            end
            
            % take a random sample of our order to repeat
            t.toBeRepeated = zeros(1,p.numRepeats); % init this as all the same
            while length(unique(t.toBeRepeated)) ~= p.numRepeats || any(t.toBeRepeated==0) % keep doing this until you have three unique repeats (none of which are zero)
                for i = 1:p.numRepeats
                    t.numSegments = floor(length(t.randomisedOrder)/p.numRepeats); % let's divide it up roughly evenly, so we're spacing the repeats out kind of equally
                    t.toBeRepeated(i) = Sample(t.randomisedOrder(t.numSegments*i-t.numSegments+1:t.numSegments*i-1)); % anywhere up to the 2nd last element of the segment (or else our next bit of logic might make the segment one longer)
                end; clear i
            end
            % now make that element+1 be the repeat - do it in a seperate loop, so
            % we don't accidentally do a repeat of something that was already
            % repeated (which would exponentially increase that item)
            for i = 1:p.numRepeats
                repeatIndex = find(t.randomisedOrder == t.toBeRepeated(i));
                t.randomisedOrder(repeatIndex+1) = t.toBeRepeated(i);
                t.repeatTrials(i) = repeatIndex+1; % pull this so we can code them
            end; clear i
            
            for trial = 1:p.numTrials
                
                % -- set up the key queue -- %
                if ~p.buttonbox
                    t.queuekeys = [KbName(p.resp_keys{1}), KbName(p.resp_keys{2}), KbName(p.resp_keys{3}), KbName(p.quitkey)]; % define the keys the queue cares about
                else
                    t.queuekeys = [KbName(p.quitkey)]; % define the keys the queue cares about
                end
                t.queuekeylist = zeros(1,256); % create a list of all possible keys (all 'turned off' i.e. zeroes)
                t.queuekeylist(t.queuekeys) = 1; % 'turn on' the keys we care about in the list (make them ones)
                KbQueueCreate([], t.queuekeylist); % initialises queue to collect response information from the list we made (not listening for response yet)
                KbQueueStart(); % starts delivering keypress info to the queue
                
                % --- pull and display the stimulus for the trial --- %
                %     showImage(p,imageLocation);
                t.thisStim = t.stimuli{t.randomisedOrder(trial)}; % pull it out of the cell
                showText(p,t.thisStim);
                
                % wait for stimulus time
                WaitSecs(p.stimTime);
                
                %% --- iti+saving --- %%
                
                Screen('Flip', p.window);
                
                WaitSecs(p.itiTime);
                
                % coding
                d.results{1,trial,test,block} = t.trialType; % code trial type
                if any(t.repeatTrials == trial) % if this is a repeat trial
                    d.results{2,trial,test,block} = 1;
                else
                    d.results{2,trial,test,block} = 0;
                end
                
                % deal with keypress (required for keyboard incl quitkey)
                [t.pressed,t.firstPress] = KbQueueCheck(); % check for keypress in the KbQueue
                if t.pressed
                    t.resp_key_name = KbName(t.firstPress); % get the name of the key used to respond - might need squiggly brackets?
                    if size(t.resp_key_name) > 1; t.resp_key_name = t.resp_key_name{1}; end % just get the first entry (if two are pressed together)
                else; t.resp_key_name = NaN; end
                t.resp_key_time = sum(t.firstPress); % get the timing info of the key used to respond
                
                % quit if quitkey
                if strcmp(t.resp_key_name,p.quitkey)
                    save(save_file); % so we don't lose all data
                    fclose('all');
                    error('%s quit by user (p.quitkey pressed)\n', mfilename);
                end
                
                % code whether they responded or not
                if p.buttonbox
                else
                    if t.pressed % since I don't think we care what they pressed (and it will have already quit if they wanted to quit)
                        d.results{3,trial,test,block} = 1;
                    else
                        d.results{3,trial,test,block} = 0;
                    end
                end
                % code correct or incorrect
                if d.results{2,trial,test,block} == d.results{3,trial,test,block} % if they responded when they should have, or didn't when they shouldn't
                    d.results{4,trial,test,block} = 1; % correct
                else
                    d.results{4,trial,test,block} = 0; % incorrect
                end
                
                save(save_file); % save all data to a .mat file
                
                %% --- post trial cleanup --- %%
                KbQueueRelease();
                
            end; clear trial
            
            save(save_file); % save all data to a .mat file
            
        end; clear test
        
        save(save_file); % save all data to a .mat file
        
    end; clear block
    
    % --- wrap up --- %
    save(save_file); % save all data to a .mat file
    Screen('CloseAll'); % clear screen
    
catch err
    save(save_file);
    ShowCursor;
    Screen('CloseAll');
    rethrow(err);
end
