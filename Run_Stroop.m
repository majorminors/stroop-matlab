%% Matching motion coherence to direction cue in MEG
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
p.testing_enabled = 0; % change to 0 if not testing (1 skips PTB synctests) - see '% test variables' below
p.fullscreen_enabled = 0;
p.skip_synctests = 0; % skip ptb synctests
p.screen_num = 0;
p.colours = {'red','blue','green'}; % used to create response coding, will assume stimulus file is named with correct colours
p.sizes = {'short','medium','tall'}; % used to create response coding
p.screen_width = 40;   % Screen width in cm
p.screen_height = 30;    % Screen height in cm
p.screen_distance = 50; % Screen distance from participant in cm
p.visual_angles = [10,11,12]; % visual angles of the stimulus expressed as a decimal - determines sizes
p.falsefonts = {'ffred','ffblue','ffgreen'}; % don't use this currently - just dealing with the ff prefix in the stimulus matrix code directly
% i'm going to hardcode four tasks to get this done quickly - see trial params

% directory mapping
if ispc; setenv('PATH',[getenv('PATH') ';C:\Program Files\MATLAB\R2018a\toolbox\CBSU\Psychtoolbox\3.0.14\PsychContributed\x64']); end % make sure psychtoolbox has all it's stuff on pc
addpath(genpath(fullfile(rootdir, 'lib'))); % add tools folder to path (includes moving_dots function which is required for dot motion, as well as an external copy of subfunctions for backwards compatibility with MATLAB)
stimdir = fullfile(rootdir, 'lib', 'stimuli');
datadir = fullfile(rootdir, 'data'); % will make a data directory if none exists
if ~exist(datadir,'dir'); mkdir(datadir); end

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
if isnan(d.participant_id); error('no participant number entered'); end

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
p.resp_keys = {'1!','2@','3#'}; % only accepts three response options
for i = 1:length(p.resp_keys)
    p.resp_coding{1,i} = p.resp_keys{i};
    p.resp_coding{2,i} = p.colours(i);
    p.resp_coding{3,i} = p.sizes(i);
end; clear i;
p.quitkey = {'q'};

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

%% define stimuli parameters

fprintf('defining stimuli params for %s\n', mfilename);

% read in stimuli files for the cue and put together a stimulus matrix
t.stimuli = dir(fullfile(stimdir,'*.png')); % get the file info
i = 0;
stim = 0;
tstim = 0;
while i < numel(t.stimuli) % loop through the files
    i = i+1;
    t.filename = t.stimuli(i).name; % get the filename
    t.this_stim = erase(t.filename,'.png'); % get rid of the extension
    if contains(t.this_stim,'-') % if there's a hyphen (i.e. not a training stimulus)
        stim = stim+1;
        p.stimuli{stim,1} = t.this_stim; % add in the stimulus name
        p.stimuli{stim,2} = imread(fullfile(stimdir, t.filename)); % read in the image
        t.front = extractBefore(p.stimuli{stim,1},'-'); % get the front
        t.back = extractAfter(p.stimuli{stim,1},'-'); % get the back
        if startsWith(t.front,'ff') % remove the ff so we can compare
            t.front = erase(t.front,'ff');
            p.stimuli{stim,3} = 'falsefont';
        else
            p.stimuli{stim,3} = 'font';
        end
        if strcmp(t.front,t.back) % compare front and back
            p.stimuli{stim,4} = 'congruent';
        else
            p.stimuli{stim,4} = 'incongruent';
        end
        p.stimuli{stim,5} = t.back;
        p.stimuli{stim,6} = t.front;
    else
        tstim = tstim+1;
        p.training_stimuli{tstim,1} = t.this_stim;
        p.training_stimuli{tstim,2} = imread(fullfile(stimdir, t.filename)); % read in the image
        if strcmp(t.this_stim,'line')
            p.training_stimuli{tstim,3} = 'line';
        else
            p.training_stimuli{tstim,3} = 'colour';
        end
        p.training_stimuli{tstim,4} = 'training';
        p.training_stimuli{tstim,5} = t.this_stim;
    end
end; clear i stim tstim t.front t.back t.this_stim t.filename;
% add those to the data structure
d.stimulus_matrix = p.stimuli;
d.training_stimulus_matrix = p.training_stimuli;

%% define trials

fprintf('defining trials for %s\n', mfilename);

% trial matrix
%   1) stimulus index
%   2) size info (1, 2, or 3)
p.trial_mat = [];
countf = 1;
countff = 1;
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
p.permutations = perms(1:4);
% select permutation based on ID
if d.participant_id >= length(p.permutations)
    t.this_permutation = mod(d.participant_id,length(p.permutations));
else; t.this_permutation = d.participant_id; end
d.permutation = p.permutations(t.this_permutation,:);

% create a procedure based on the trial matrices and permutation
t.size_counter = 0; % something to catch the first colour procedure
t.colour_counter = 0; % something to catch the first size procedure
t.perm_counter = 1; % something to index through the permutation
t.proc_counter = 0; % something to index through the procedures
t.proc_end = length(d.permutation); % something to end the while loop
while t.proc_counter < t.proc_end
    t.proc_counter = t.proc_counter+1;
    if d.permutation(t.perm_counter) == 1 || d.permutation(t.perm_counter) == 3
        t.colour_counter = t.colour_counter+1;
        t.trial_feature = 'colour';
    elseif d.permutation(t.perm_counter) == 2 || d.permutation(t.perm_counter) == 4
        t.size_counter = t.size_counter+1;
        t.trial_feature = 'size';
    end
    if t.colour_counter == 1
        t.trial_mat = p.trn_mat;
        t.proc_end = t.proc_end+1;
        t.trial_type = 'colour_training';
    elseif t.size_counter == 1
        t.trial_mat = p.trn_mat;
        t.proc_end = t.proc_end+1;
        t.trial_type = 'size_training';
    else
        if d.permutation(t.perm_counter) == 1 || d.permutation(t.perm_counter) == 2
            t.perm_counter = t.perm_counter+1;
            t.trial_mat = p.trial_mat(:,:,1);
            t.trial_type = 'font';
        elseif d.permutation(t.perm_counter) == 3 || d.permutation(t.perm_counter) == 4
            t.perm_counter = t.perm_counter+1;
            t.trial_mat = p.trial_mat(:,:,2);
            t.trial_type = 'falsefont';
        end
    end
    d.procedure(:,:,t.proc_counter) = t.trial_mat;
    d.procedure = Shuffle(d.procedure,[2]); % shuffle rows independently on each page
    d.procedure_code(t.proc_counter,:) = {t.trial_feature,t.trial_type};
end

%% exp start

fprintf('running experiment %s\n', mfilename);
%% define results matrix
t.result_counter = 0;
d.results = []; % initialise a results matrix
%% define some training stuff
d.training_results = [];
t.training_result_counter = 0;
t.train_size = 0;
t.train_colour = 0;

try
    % open screen
    if p.fullscreen_enabled % zero out p.window_size if p.fullscreen_enabled = 1
        p.window_size=[];
    end
    [p.win,p.rect] = Screen('OpenWindow',p.screen_num,p.bg_colour,p.window_size);
    Screen('BlendFunction',p.win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); % allows transparency in .png images
    Screen('TextSize', p.win, p.text_size); % set the text size
    % then need some info based on the screen for later
    %p.frame_rate = 1/Screen('GetFlipInterval', p.win); % is Hz
    p.resolution = p.rect([3,4]); % pull resolution info from p.rect - used to scale cue image
    HideCursor;
    WaitSecs(0.5); % warm up
    
    %% start procedure
    for proc = 1:size(d.procedure,3)
        fprintf('procedure %u of %u\n',proc,size(d.procedure,3)); % report trial number to command window
        t.this_proc = d.procedure(:,:,proc);
        t.this_feature = d.procedure_code(proc,1);
        if contains(d.procedure_code(proc,2),'training')
            t.training = 1;
            t.training_type = extractBefore(d.procedure_code(proc,2),'_');
        else; t.trianing = 0; end
        
        %% start trial
        for trial = 1:size(t.this_proc,1)
            fprintf('trial %u of %u\n',trial,size(t.this_proc,1)); % report trial number to command window
            t.this_trial = t.this_proc(trial,:);
            t.this_stim_idx = t.this_trial(1);
            t.this_size = t.this_triaql(2);
            if t.training
                if strcmp(t.training_type,'colour')
                    t .this_size = 2;
                    t.stimulus = cell2mat(p.training_stimuli(find(strcmp(p.training_stimuli(t.this_stim_idx,1),p.resp_coding{2,t.this_stim_idx})),2));
                elseif strcmp(t.training_type,'size')
                    t.stimulus = cell2mat(p.training_stimuli(find(strcmp(p.training_stimuli(:,1),'line')),2));
                end
            else; t.stimulus = cell2mat(p.stimuli(t.this_stim_idx,2)); end
            t.result_counter = t.result_counter+1; % iterate results counter
            
            % set up a queue to collect response info
            t.queuekeys = [KbName(p.resp_keys{1}), KbName(p.resp_keys{2}), KbName(p.resp_keys{3}), KbName(p.quitkey)]; % define the keys the queue cares about
            t.queuekeylist = zeros(1,256); % create a list of all possible keys (all 'turned off' i.e. zeroes)
            t.queuekeylist(t.queuekeys) = 1; % 'turn on' the keys we care about in the list (make them ones)21
            KbQueueCreate([], t.queuekeylist); % initialises queue to collect response information from the list we made (not listening for response yet)
            KbQueueStart(); % starts delivering keypress info to the queue
            
            % make the texture and scale it
            t.stim_tex = Screen('MakeTexture', p.win, t.stimulus);
            [t.tex_size1, t.tex_size2, t.tex_size3] = size(t.stim_tex); % get size of texture
            t.aspectratio = t.tex_size2/t.tex_size1; % get the aspect ratio of the image for scaling purposes
            t.imageheight = angle2pix(p,p.visual_angles(t.this_size)); % scale the height of the image using the desired visual angle
            t.imagewidth = t.imageheight .* t.aspectratio; % get the scaled width, constrained by the aspect ratio of the image
            
            % parameterise the rect to display cue in
            t.imgrect = [0 0 t.imagewidth t.imageheight]; % make a scaled rect for the cue
            t.rect = CenterRectOnPointd(t.imgrect,p.resolution(1,1)/2,p.resolution(1,2)/2); % offset it for the centre of the window
            
            % iti
            % we want a fixation? or at least a blank screen?
            WaitSecs(p.iti_time);
            
            % then display cue
            Screen('DrawTexture', p.win, t.stim_tex, [], t.rect); % draws the cue
            t.cue_onset = Screen('Flip', p.win); % pull the time of the screen flip from the flip function while flipping
            WaitSecs(p.trial_duration); % wait for trial
            
            %% deal with response
            
            % deal with keypress
            [t.pressed,t.firstPress] = KbQueueCheck(); % check for keypress in the KbQueue
            if t.pressed
                t.resp_key_name = KbName(t.firstPress); % get the name of the key used to respond - might need squiggly brackets?
                t.resp_key_name = t.resp_key_name{1}; % just get the first entry (if two are pressed together)
            else; t.resp_key_name = NaN; end
            t.resp_key_time = sum(t.firstPress); % get the timing info of the key used to respond
            
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
                if strcmp(p.resp_coding{2,t.resp_code},p.stimuli(t.this_stim_idx,5))
                    t.correct = 1;
                    t.feedback = 'correct';
                else
                    t.correct = 0;
                    t.feedback = 'incorrect';
                end
            end
            
            % quit if quitkey
            if strcmp(t.resp_key_name,p.quitkey)
                fclose('all');
                error('%s quit by user (p.quitkey pressed)\n', mfilename);
            end
            
            % display trialwise feedback
            DrawFormattedText(p.win, t.feedback, 'center', 'center', p.text_colour); %display feedback
            Screen('Flip', p.win);
            WaitSecs(p.feedback_time);
            Screen('Flip', p.win);
            
            %% post trial cleanup
            KbQueueRelease();
            
            d.results(t.result_counter,1) = t.rt;
            d.results(t.result_counter,2) = t.correct;
            d.results(t.result_counter,3) = t.this_stim_idx;
            
            % end trial
        end; clear trial;
        
        save(save_file); % so we don't lose all data in a crash
        
        % end procedure
    end; clear proc;
    
    %% wrap up
    
    save(save_file); % save the data
    
    % tell them it's over
    DrawFormattedText(p.win,'done!', 'center', 'center', p.text_colour); % tell them it's over!
    Screen('Flip', p.win);
    WaitSecs(1);
    Screen('Flip', p.win);
    
    % close screen
    ShowCursor;
    KbQueueRelease(); %KbReleaseWait();
    if p.MEG_enabled == 1; MEG.delete; end % stop MEG from limiting button presses
    clear ans; % clear extraneous stuff
    Screen('Close',p.win);
    
    fprintf('done running %s\n', mfilename);
    
catch err
    save(save_file);
    ShowCursor;
    sca; %Screen('Close',p.win);
    rethrow(err);
end
