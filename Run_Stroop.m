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
t = struct(); % another structure for untidy temp floating variables

% initial settings
rootdir = pwd; % root directory - used to inform directory mappings
p.vocal_stroop = 0;
p.manual_stroop = 1;
p.scanning = 0;

% tech settings
p.screen_num = 0; % if multiple monitors, else 0
p.buttonbox = 0; % or keyboard
p.max_height = 600; % in rows for the largest size scale
% Set fMRI parameters
if p.scanning
    p.tr = 1.208;                  % TR in s % CHANGE THIS LINE
    p.num_baseline_triggers = 4;   % Number of triggers we record as a baseline at the start of each block
    delay = 4000;                  % Wait time for response
    % Initialise a scansync session
    scansync('reset',p.tr)         % also needed to record button box responses
end


% testing settings
p.testing_enabled = 1; % change to 0 if not testing (1 skips PTB synctests) - see '% test variables' below
p.fullscreen_enabled = 0;
p.skip_synctests = 0; % skip ptb synctests

% keys
p.bad_buttons = 4; % if p.buttonbox, what buttons are invalid? this assumes you're using scansync numbers 1-3 or else you need to address the response coding for correct/incorrect
p.resp_keys = {'1!','2@','3#'}; % only accepts three response options
p.quitkey = {'q'}; % keep this for vocal and manual

% stimulus settings
p.size_scales = [0.5,0.7,1]; % scales for image sizing in trial
p.fixation_size = 40; % px
p.fixation_thickness = 4; % px
p.colours = {'red','blue','green'}; % used to create response coding, will assume stimulus file is named with correct colours
p.sizes = {'short','medium','tall'}; % used to create response coding
p.vocal_threshold = 0.1; % between 0 and 1

if p.vocal_stroop && p.manual_stroop; error('you have selected both vocal and manual stroop!'); end
if p.vocal_stroop && p.buttonbox; error('you are trying to do both button box and vocal, are you sure?'); end

% directory mapping
%if ispc; setenv('PATH',[getenv('PATH') ';C:\Program Files\MATLAB\R2018a\toolbox\CBSU\Psychtoolbox\3.0.14\PsychContributed\x64']); end % make sure psychtoolbox has all it's stuff on pc
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
if p.vocal_stroop
    InitializePsychSound;
    PsychPortAudio('Verbosity', verbose);
end

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

% create a structure for saving
if p.vocal_stroop; t.exp_type = 'vocal'; elseif p.manual_stroop; t.exp_type = 'manual'; end
% create a savedir
savedir = fullfile(datadir, [num2str(d.participant_id,'S%02d'), '_',t.exp_type]); % will make a data directory if none exists
if ~exist(savedir,'dir'); mkdir(savedir); end
% create a save file name
save_file_name = [num2str(d.participant_id,'S%02d'),'_',t.exp_type,'_',mfilename];
save_file = fullfile(savedir, save_file_name);
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

% define display info
p.bg_colour = [255 255 255];
p.text_colour = [0 0 0]; % colour of instructional text
p.text_size = 40; % size of text
p.window_size = [0 0 1200 800]; % size of window when ~p.fullscreen_enabled

% timing info
p.iti_time = 0.3; % inter trial inteval time
p.trial_duration = 1.5; % seconds for the stimuli to be displayed
p.feedback_time = 0.5; % period to display feedback after response
p.min_stim_time = 0.2; % time to not show the stimulus

d.timestamps = struct()
d.initTime = [];

%% define stimuli parameters

fprintf('defining stimuli params for %s\n', mfilename);

% read in stimuli files for the cue and put together a stimulus matrix
% defines the path to the stimulus, reads in the image to matrix, then codes whether it's (false)font and (in)congruent
t.stimuli = dir(fullfile(stimdir,'*.png')); % get the file info
i = 0; % an index to work with
stim = 0; % a stimulus counter
tstim = 0; % a training stimulus counter
while i < numel(t.stimuli) % loop through the files
    i = i+1;
    t.filename = t.stimuli(i).name; % get the filename
    t.this_stim = t.filename(1:regexp(t.filename,'\.')-1); % get rid of the extension from the '.' on
    [t.imported_stim,~,t.imported_alpha] = imread(fullfile(stimdir, t.filename)); % read in the image
    t.scaled_stim = imresize(t.imported_stim, [p.max_height,NaN]); % scale images to a specified number of rows, maintaining aspect ratio
    t.scaled_alpha = imresize(t.imported_alpha, [p.max_height,NaN]);
    t.scaled_stim(:,:,4) = t.scaled_alpha;
    if regexp(t.this_stim,'-') % if there's a hyphen (i.e. not a training stimulus and has two feature attributes in the filename)
        stim = stim+1; % iterate stimulus counter
        p.stimuli{stim,1} = t.this_stim; % add in the stimulus name
        p.stimuli{stim,2} = t.scaled_stim;
        t.front = t.this_stim(1:regexp(t.this_stim,'-')-1); % get the front of the name
        t.back = t.this_stim(regexp(t.this_stim,'-')+1:end); % get the back of the name
        if regexp(t.front,'ff') % if there's an 'ff' in t.front
            t.front = t.front(regexp(t.front,'ff')+2:end); % remove it
            p.stimuli{stim,3} = 'falsefont'; % code as false font
        else
            p.stimuli{stim,3} = 'font'; % code as font
        end
        if strcmp(t.front,t.back) % compare front and back of the name
            p.stimuli{stim,4} = 'congruent'; % if matches, congruent
        else
            p.stimuli{stim,4} = 'incongruent'; % if doesn't match, incongruent
        end
        p.stimuli{stim,5} = t.back; % add the back to the matrix (colour information)
        p.stimuli{stim,6} = t.front; % add the front to the matrix (print information)
    else
        tstim = tstim+1; % iterate training stimulus counter
        p.training_stimuli{tstim,1} = t.this_stim; % get the stimulus name
        p.training_stimuli{tstim,2} = t.scaled_stim; % read in the image
        if strcmp(t.this_stim,'line') % if it's the line stimulus
            p.training_stimuli{tstim,3} = 'line'; % code as such
        else
            p.training_stimuli{tstim,3} = 'colour'; % else it's one of the colour training stims
        end
        p.training_stimuli{tstim,4} = 'training'; % code as training
    end
    
end; clear i stim tstim
% save those to the data structure
d.stimulus_matrix = p.stimuli;
d.training_stimulus_matrix = p.training_stimuli;

%% define trials

fprintf('defining trials for %s\n', mfilename);

% trial matrix
%   1) index of position in the stimulus matrix
%   2) size info (1, 2, or 3)
% third dimension delineates font trials from false font trials
p.trial_mat = [];
countf = 1; % counter for the fonts
countff = 1; % counter for the false fonts
for i = 1:numel(p.stimuli(:,1))
    if strcmp(p.stimuli{i,3},'font') && strcmp(p.stimuli{i,4},'congruent')
        p.trial_mat(countf,1,1) = i;
        countf=countf+1;
    elseif strcmp(p.stimuli{i,3},'font') && strcmp(p.stimuli{i,4},'incongruent')
        p.trial_mat(countf,1,1) = i;
        countf=countf+1;
    elseif strcmp(p.stimuli{i,3},'falsefont') && strcmp(p.stimuli{i,4},'congruent')
        p.trial_mat(countff,1,2) = i;
        countff=countff+1;
    elseif strcmp(p.stimuli{i,3},'falsefont') && strcmp(p.stimuli{i,4},'incongruent')
        p.trial_mat(countff,1,2) = i;
        countff=countff+1;
    end
end; clear i countf countff;
% duplicate congruent trials
idx1 = find(strcmp(p.stimuli(p.trial_mat(:,1,1),4),'congruent'));
idx2 = find(strcmp(p.stimuli(p.trial_mat(:,1,2),4),'congruent'));
tmp(:,:,1) = p.trial_mat(idx1,:,1);
tmp(:,:,2) = p.trial_mat(idx2,:,2);
p.trial_mat = [p.trial_mat;tmp]; clear tmp idx1 idx2;
% duplicate three times for the three sizes
p.trial_mat = [p.trial_mat;p.trial_mat;p.trial_mat];
% add sizes
p.trial_mat(:,2,1) = reshape(repmat(1:3,length(p.trial_mat(:,1))/3,1),[],1);
p.trial_mat(:,2,2) = reshape(repmat(1:3,length(p.trial_mat(:,1))/3,1),[],1);

% training matrix of equiv size for colour only and size only trials
%   1) colour index
%   2) size
p.trn_mat(:,1) = p.trial_mat(:,2,1);
p.trn_mat(:,2) = reshape(repmat(1:3,length(p.trn_mat(:,1))/3/3,3),[],1);

% permute an order
p.permutations = perms(1:4); % get all permutations of vector
% select permutation based on ID
if d.participant_id >= length(p.permutations)
    t.this_permutation = mod(d.participant_id,length(p.permutations)); % so ids will neatly divide up into the permutations
else
    t.this_permutation = d.participant_id;
end
d.permutation = p.permutations(t.this_permutation,:); % collect the permutation for this participant

% create a procedure based on the trial matrices and permutation
t.size_counter = 0; % something to catch the first colour procedure - starts at 0
t.colour_counter = 0; % something to catch the first size procedure - starts at 0
t.perm_counter = 1; % something to index through the permutation - starts at 1
t.proc_counter = 0; % something to index through the procedures - starts at 0
t.proc_end = length(d.permutation); % something to end the while loop
while t.proc_counter < t.proc_end % while we have procedures to loop through
    t.proc_counter = t.proc_counter+1; % iterate up one procedure
    if d.permutation(t.perm_counter) == 1 || d.permutation(t.perm_counter) == 3 % if this procudure is a 1 or a 3
        t.colour_counter = t.colour_counter+1; % it's a colour trial
        t.trial_feature = 'colour';
    elseif d.permutation(t.perm_counter) == 2 || d.permutation(t.perm_counter) == 4 % if a 2 or 4
        t.size_counter = t.size_counter+1; % it's a size trial
        t.trial_feature = 'size';
    end
    if t.colour_counter == 1 % if it's the first time we've had a colour trial
        t.trial_mat = p.trn_mat; % pop in a training block
        t.proc_end = t.proc_end+1; % add one to the procedure loop ender since we just used one up
        t.trial_type = 'training';
    elseif t.size_counter == 1 % if it's the first time we've had a size trial
        t.trial_mat = p.trn_mat; % pop in a training block
        t.proc_end = t.proc_end+1; % add one to the procedure loop ender since we just used one up
        t.trial_type = 'training';
    else % else, pop in a test block
        if d.permutation(t.perm_counter) == 1 || d.permutation(t.perm_counter) == 2 % if the procedure is a 2 or a 3
            t.perm_counter = t.perm_counter+1; % iterate the permutation counter
            t.trial_mat = p.trial_mat(:,:,1); % add in the trial matrix for fonts
            t.trial_type = 'font'; % code it as a font procedure
        elseif d.permutation(t.perm_counter) == 3 || d.permutation(t.perm_counter) == 4 % if its a 3 or 4
            t.perm_counter = t.perm_counter+1; % iterate the permutation counter
            t.trial_mat = p.trial_mat(:,:,2); % add in the trial matrix for false fonts
            t.trial_type = 'falsefont'; % code it as a false font
        end
    end
    d.procedure(:,:,t.proc_counter) = t.trial_mat; % add that trial matrix to the procedure matrix, the third dimension indicates which procedure
    d.procedure_code(t.proc_counter,:) = {t.trial_feature,t.trial_type}; % get a code of what procedure is on what page
end
d.procedure = NewShuffle(d.procedure,[2]); % shuffle rows independently on each page/third dimension (PTB shuffle (copied here as NewShuffle because one computer I was testing on had some old version?))

%% exp start
fprintf('running experiment %s\n', mfilename);

% define results matrix
d.results = []; % initialise a results matrix

try
    % open screen
    if p.fullscreen_enabled % zero out p.window_size if p.fullscreen_enabled = 1
        p.window_size=[];
    end
    [p.win,p.rect] = Screen('OpenWindow',p.screen_num,p.bg_colour,p.window_size);
    Screen('BlendFunction',p.win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); % allows transparency in .png images
    Screen('TextSize', p.win, p.text_size); % set the text size
    [p.xCenter, p.yCenter] = RectCenter(p.rect); % get the center
    HideCursor;
    WaitSecs(0.5); % warm up
    
    
    for proc = 1:size(d.procedure,3) % loop through procedures
        fprintf('procedure %u of %u\n',proc,size(d.procedure,3)); % report procedure number to command window
        t.this_proc = d.procedure(:,:,proc); % get the procedure from the procedure matrix
        t.this_feature = d.procedure_code(proc,1); % get the trial attended feature (size/colour)
        if strcmp(d.procedure_code(proc,2),'training') % if it's a training trial
            t.training = 1;
            t.training_type = d.procedure_code(proc,1); % we're going to do something different, so get the feature again
        else
            t.training = 0;
        end
        
        % -- AW 23/8/19, wait for experimenter (wil PA blib is running) --
        DrawFormattedText(MainWindow, 'Experimenter: start run when ready', 'center', 'center', p.white)
        Screen('Flip', MainWindow);
        Timestamp('Instruc press space onset', [], proc);
        KbWait()
        
        
        % --- wait until TTL (this is after 4 dummy scans) ---
        if ~p.scanning %msg experimenter
            Wait(0.1);
            DrawFormattedText(MainWindow, 'Dummy mode: press any key to start', 'center', 'center', p.white)
            Screen('Flip', MainWindow);
            Timestamp('Instruc press space onset', [], proc);
            KbWait()
            d.initTime(proc)=GetSecs();
            
        else
            DrawFormattedText(MainWindow, 'Waiting for scanner', 'center', 'center', p.white)
            Screen('Flip', MainWindow);
            Timestamp('Instruc wait TTL onset', [], proc);
            
            %______________________________________________________
            % CS 19
            
            [pulse_time,~,daqstate] = scansync(1,Inf);
            d.initTime(proc)=GetSecs();
            
            % NEW
            Timestamp('TR', [], proc);
            
        end
        
        Timestamp(['Start of Procedure ' d.procedure_code(proc,2) ' ' d.procedure_code(proc,1)], d.initTime(proc), proc);
        %% trial loop
        for trial = 1:size(t.this_proc,1)
            fprintf('trial %u of %u\n',trial,size(t.this_proc,1)); % report trial number to command window
            Timestamp(['Start of Trial ' d.procedure_code(proc,2) ' ' d.procedure_code(proc,1)], d.initTime(proc), proc, trial);
            t.this_trial = t.this_proc(trial,:); % get the trial information
            t.this_stim_idx = t.this_trial(1); % get the index of the stimulus for the trial
            t.this_size = t.this_trial(2); % get the size of the trial
            if t.training
                if strcmp(t.training_type,'colour')
                    t.this_size = 2; % select medium size
                    t.stimulus = cell2mat(p.training_stimuli(find(strcmp(p.training_stimuli(t.this_stim_idx,1),p.resp_coding{2,t.this_stim_idx})),2));
                    t.corr_colour = p.training_stimuli(find(strcmp(p.training_stimuli(t.this_stim_idx,1),p.resp_coding{2,t.this_stim_idx})),5);
                elseif strcmp(t.training_type,'size')
                    t.stimulus = cell2mat(p.training_stimuli(find(strcmp(p.training_stimuli(:,1),'line')),2));
                end
            else
                t.stimulus = cell2mat(p.stimuli(t.this_stim_idx,2));
                t.corr_colour = p.stimuli(t.this_stim_idx,5);
            end
            
            % resize based on the size required
            t.stimulus = imresize(t.stimulus,p.size_scales(t.this_size));
            
            %             if you want to test
            % t.stimulus = cell2mat(p.stimuli(4,2));
            
            % set up a queue to collect response info
            if p.manual_stroop && ~p.buttonbox
                t.queuekeys = [KbName(p.resp_keys{1}), KbName(p.resp_keys{2}), KbName(p.resp_keys{3}), KbName(p.quitkey)]; % define the keys the queue cares about
            else % if vocal stroop or p.buttonbox
                t.queuekeys = [KbName(p.quitkey)]; % define the keys the queue cares about
            end
            t.queuekeylist = zeros(1,256); % create a list of all possible keys (all 'turned off' i.e. zeroes)
            t.queuekeylist(t.queuekeys) = 1; % 'turn on' the keys we care about in the list (make them ones)
            KbQueueCreate([], t.queuekeylist); % initialises queue to collect response information from the list we made (not listening for response yet)
            KbQueueStart(); % starts delivering keypress info to the queue
            
            % iti
            % get coordinates for centering stimuli from fixation parameters
            p.xCoords = [-p.fixation_size p.fixation_size 0 0];
            p.yCoords = [0 0 -p.fixation_size p.fixation_size];
            p.allCoords = [p.xCoords; p.yCoords];
            
            Screen('DrawLines', p.win, p.allCoords, p.fixation_thickness, p.text_colour, [p.xCenter p.yCenter], 2);
            Screen('Flip', p.win);
            WaitSecs(p.iti_time);
            
            % make the texture and draw it
            t.stim_tex = Screen('MakeTexture', p.win, t.stimulus);
            Screen('DrawTexture', p.win, t.stim_tex); % draws the cue
            
            % then display cue
            t.cue_onset = Screen('Flip', p.win); % pull the time of the screen flip from the flip function while flipping
            Timestamp(['Cue Onset ' d.procedure_code(proc,2) ' ' d.procedure_code(proc,1)], d.initTime(proc), proc, trial);
            if p.vocal_stroop
                t.rt = getVoiceResponse(p.vocal_threshold, p.trial_duration, fullfile(save_file,'_audio'), 'savemode', 2);
            elseif p.manual_stroop
                if ~p.buttonbox
                    WaitSecs(p.trial_duration); % wait for trial
                else
                    t.resp = scansync([],GetSecs+p.trial_duration/1000);
                end
            end
            %% deal with response
            
            % deal with keypress (required for both manual keyboard and quitkey in vocal or p.buttonbox)
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
            
            if p.manual_stroop % code response
                if p.buttonbox
                    % Get the response button and rt
                    if any(isfinite(t.resp))
                        [t.buttontime,t.buttonpress] = min(t.resp); % keypress returns values 1:4
                        t.rt = t.buttontime-t.cue_onset; % Subtract stim onset time to get the RT
                        if ismember(t.buttonpress,t.bad_buttons) % code bad buttons as invalid
                            t.resp_code = 0; % code invalid response
                            t.feedback = 'no valid response';
                            t.rt = NaN;
                        else % get buttonpress as code
                            t.resp_code = t.buttonpress;
                        end
                    else
                        t.resp_code = 0; % code invalid response
                        t.feedback = 'no valid response';
                        t.rt = NaN;
                    end
                else % if keyboard
                    t.rt = t.resp_key_time - t.cue_onset; % rt is the timing of key info - time of dots onset (if you get minus values something's wrong with how we deal with nil/early responses)
                    % save the response key (as a code)
                    if t.resp_key_name == p.resp_keys{1}
                        t.resp_code = 1; % code response 1 pressed
                    elseif t.resp_key_name == p.resp_keys{2}
                        t.resp_code = 2; % code response 2 pressed
                    elseif t.resp_key_name == p.resp_keys{3}
                        t.resp_code = 3; % code response 2 pressed
                    else
                        t.resp_code = 0; % code invalid response
                        t.feedback = 'no valid response';
                    end
                end
                
                % score response
                if strcmp(t.this_feature, 'size')
                    if t.this_size == t.resp_code
                        t.correct = 1;
                        t.feedback = 'correct';
                    else
                        t.correct = 0;
                        t.feedback = 'incorrect';
                    end
                elseif strcmp(t.this_feature, 'colour')
                    if strcmp(p.colours{t.resp_code},t.corr_colour)
                        t.correct = 1;
                        t.feedback = 'correct';
                    else
                        t.correct = 0;
                        t.feedback = 'incorrect';
                    end
                end
                Timestamp(['Response ' d.procedure_code(proc,2) ' ' d.procedure_code(proc,1)], d.initTime(proc), proc, trial)
                % display trialwise feedback
                DrawFormattedText(p.win, t.feedback, 'center', 'center', p.text_colour); % display feedback
                Screen('Flip', p.win);
                WaitSecs(p.feedback_time);
                Screen('Flip', p.win);
                
                % collate the results - each page is a procedure
                d.results(trial,1,proc) = t.rt;
                if p.manual_stroop
                    d.results(trial,2,proc) = t.correct;
                else
                    d.results(trial,2,proc) = -2;
                end
                d.results(trial,3,proc) = t.this_stim_idx;
            end % end manual stroop coding
            
            % end trial
            Timestamp(['End of Trial ' d.procedure_code(proc,2) ' ' d.procedure_code(proc,1)], d.initTime(proc), proc, trial);
            
            %% post trial cleanup
            KbQueueRelease();
        end; clear trial;
        
        save(save_file); % so we don't lose all data in a crash
        Timestamp(['End of Procedure ' d.procedure_code(proc,2) ' ' d.procedure_code(proc,1)], d.initTime(proc), proc, 0);
        
        % end procedure
    end; clear proc;
    
    %% wrap up
    
    save(save_file); % save the data
    
    Timestamp('End experiment', []);
    
    % tell them it's over
    DrawFormattedText(p.win,'done!', 'center', 'center', p.text_colour); % tell them it's over!
    Screen('Flip', p.win);
    WaitSecs(1);
    Screen('Flip', p.win);
    
    % close screen
    ShowCursor;
    KbQueueRelease(); %KbReleaseWait();
    clear ans; % clear extraneous stuff
    Screen('Close',p.win);
    
    fprintf('done running %s\n', mfilename);
    
catch err
    save(save_file);
    ShowCursor;
    sca; %Screen('Close',p.win);
    rethrow(err);
end
