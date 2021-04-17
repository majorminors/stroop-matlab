%% Stroop task
% Dorian Minors
% Created: JAN21
% Last Edit: APR21
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
p.scanning = 1;
p.buttonbox = 1; % or keyboard

% testing settings
p.testing_enabled = 0; % change to 0 if not testing (1 skips PTB synctests) - see '% test variables' below
p.fullscreen_enabled = 1;
p.skip_synctests = 0; % skip ptb synctests

% block settings
p.num_blocks = 10; % overridden to training blocks for training and practice runs
p.num_training_blocks = 1; % will override num_blocks during training and practice

proc_scriptname = 'Procedure_Gen'; % name of script that generated stimulus and procedure matrices (appended as mfilename to participant savefile)

% tech settings
p.screen_num = 0; % if multiple monitors, else 0
% Set fMRI parameters
if p.scanning
    p.tr = 1.208;                  % TR in s % CHANGE THIS LINE
    % Initialise a scansync session
    scansync('reset',p.tr);         % also needed to record button box responses
end

% keys
p.bad_buttons = 4; % if p.buttonbox, what buttons are invalid? this assumes you're using scansync numbers 1-3 or else you need to address the response coding for correct/incorrect
p.resp_keys = {'1!','2@','3#'}; % only accepts three response options
p.quitkey = {'q'}; % keep this for vocal and manual

% stimulus settings
p.size_scales = [0.3,0.5,0.7]; % scales for image sizing in trial
p.fixation_size = 40; % px
p.fixation_thickness = 4; % px
p.colours = {'red','blue','green'}; % used to create response coding, will assume stimulus file is named with correct colours
p.sizes = {'short','medium','tall'}; % used to create response coding
p.vocal_threshold = 0.1; % between 0 and 1

% define display info
p.bg_colour = [255/2 255/2 255/2]; % this is white/2=grey
p.text_colour = [0 0 0]; % colour of instructional text
p.text_size = 40; % size of text
p.window_size = [0 0 1200 800]; % size of window when ~p.fullscreen_enabled

% timing info
p.iti_time = 0.3; % inter trial inteval time
p.trial_duration = 1.5; % seconds for the stimuli to be displayed
p.trial_feedback_time = 0.5; % period to display feedback after response
p.block_feedback_time = 1; % period to display feedback after block

%--------%
% checks %
%--------%

if p.vocal_stroop && p.manual_stroop; error('you have selected both vocal and manual stroop!'); end
if p.vocal_stroop && p.buttonbox; error('you are trying to do both button box and vocal, are you sure?'); end

%-------------------%
% directory mapping %
%-------------------%

%if ispc; setenv('PATH',[getenv('PATH') ';C:\Program Files\MATLAB\R2018a\toolbox\CBSU\Psychtoolbox\3.0.14\PsychContributed\x64']); end % make sure psychtoolbox has all it's stuff on pc
addpath(genpath(fullfile(rootdir, 'lib'))); % add tools folder to path (includes moving_dots function which is required for dot motion, as well as an external copy of subfunctions for backwards compatibility with MATLAB)
stimdir = fullfile(rootdir, 'lib', 'stimuli');
datadir = fullfile(rootdir, 'data'); % will make a data directory if none exists
if ~exist(datadir,'dir'); mkdir(datadir); end

%--------------------%
% psychtoolbox setup %
%--------------------%

% testing setup
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
    PsychPortAudio('Verbosity', 3);
end

AssertOpenGL; % check Psychtoolbox (on OpenGL) and Screen() is working
KbName('UnifyKeyNames'); % makes key mappings compatible (mac/win)
rng('shuffle'); % seed rng using date and time

%-------------------%
% participant setup %
%-------------------%

% set up participant info and save
t.prompt = {'enter participant number:',...
    'enter run/procedure number:',...
    'is this a practice run? (1 or 0 + overridden during training)'}; % prompt a dialog to enter subject info
t.prompt_defaultans = {num2str(99),num2str(1),num2str(1)}; % default answers corresponding to prompts
t.prompt_rsp = inputdlg(t.prompt, 'enter participant info', 1, t.prompt_defaultans); % save dialog responses
d.participant_id = str2double(t.prompt_rsp{1}); % add subject number to 'd'
p.procedure_index = str2double(t.prompt_rsp{2}); % add the procedure index, so we can pull the trials from the procedure matrix later
p.practice = str2double(t.prompt_rsp{3});

% check participant info has been entered correctly for the script
if isnan(d.participant_id); error('no participant number entered'); end

% code for save structure
if p.vocal_stroop; t.exp_type = 'vocal'; elseif p.manual_stroop; t.exp_type = 'manual'; end

% search for a savedir (where the procedure file should be)
savedir = fullfile(datadir, [num2str(d.participant_id,'S%02d'), '_',t.exp_type]); % will make a data directory if none exists
if ~exist(savedir,'dir'); error('no savedir, have you run the procedure generator?'); end

% --- check procedure file exists for this participant --- %

p.procedure_file = [num2str(d.participant_id,'S%02d'),'_',t.exp_type,'_',proc_scriptname,'.mat'];
disp('searching for procedure file:')
disp(p.procedure_file)
if ~exist([savedir,filesep,p.procedure_file], 'file')
    error('there is no procedure file for this participant');
else
    disp('found... loading')
    disp('checking id matches')
    imported = load(fullfile(savedir,p.procedure_file),'d');
    if d.participant_id ~= imported.d.participant_id
        error('id from procedure generation does not match')
    else
        d.all_procedures = imported.d.procedure;
        d.all_procedure_codes = imported.d.procedure_code;
        d.stimulus_matrix = imported.d.stimulus_matrix;
        d.training_stimuli = imported.d.training_stimulus_matrix;
        
        % so we have, if we want:
        %    d.stimulus_matrix
        %    d.training_stimulus_matrix
        %    d.participant_id
        %    d.permutation
        %    d.procedure where 3rd dimension corresponds to one procedure
        %    d.procedure_code where 1st dimension corresponds to one procedure
    end
end; clear imported;

% --- get the procedure information we need for this run --- %

d.procedure = d.all_procedures(:,:,p.procedure_index);
t.procedure_code = d.all_procedure_codes(p.procedure_index,:);
d.attended_feature = t.procedure_code{1};
d.procedure_type = t.procedure_code{2};

% do a lil check

fprintf('attended feature is: %s\n', d.attended_feature);
fprintf('procedure_type is: %s\n', d.procedure_type);

t.prompt = 'look right (y/n)? [y]';
t.ok = input(t.prompt,'s');
if isempty(t.ok); t.ok = 'y'; end 
if ~strcmp(t.ok,'y'); error('no good'); end

% --- create a save file name --- %

save_file_name = [num2str(d.participant_id,'S%02d'),'_',t.exp_type,'_',mfilename,'_',d.attended_feature,'_',d.procedure_type];
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


%% exp start
fprintf('running experiment %s\n', mfilename);

d.initTime = [];
d.timestamps = Timestamp('Initialise timestamp structure', []);

%----------------------------%
% prepopulate results matrix %
%----------------------------%

d.results = cell(size(d.procedure,1),5,p.num_blocks); % initialise a results matrix the length of the trials
% extra dimension for blocks deleted for practice and training
d.results(:,1,:) = {d.attended_feature};
d.results(:,2,:) = {d.procedure_type};
% 3) rt
% 4) correct (meaningful only for manual, otherwise -2)
% 5) stimulus index (to get from d.stimulus_matrix the stimulus information)

%----------%
% commence %
%----------%

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
    
    % --- do some edits based on practice/training --- %
    
    if strcmp(d.procedure_type,'training') % if it's a training trial
        disp('training procedure')
        t.training = 1;
            if p.scanning == 1; warning('you had p.scanning on, but this is a training block so im going to turn it off');p.scanning = 0; end
        t.training_type = d.attended_feature; % we're going to use a more legible name for this
        p.num_blocks = p.num_training_blocks; % override num blocks
        d.results(:,:,2:end) = []; % delete the extra dimensions - only one for training
        p.practice = 0; % override practice if accidentally on
    else
        t.training = 0;
        if p.practice
            p.num_blocks = p.num_training_blocks; % override num blocks
            if p.scanning == 1; warning('you had p.scanning on, but this is a practice block so im going to turn it off');p.scanning = 0; end
            d.results(:,:,2:end) = []; % delete the extra dimensions - only one for training
        end
    end
    
    % -- AW 23/8/19, wait for experimenter (wil PA blib is running) --
    DrawFormattedText(p.win, 'Experimenter: start run when ready', 'center', 'center', p.text_colour)
    Screen('Flip', p.win);
    t.ts = Timestamp('Instruc press space onset', []);
    d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
    WaitSecs(1); % so you hopefully don't have keys down!
    KbWait();
    
    
    % --- wait until TTL (this is after 4 dummy scans) ---
    if ~p.scanning %msg experimenter
        WaitSecs(0.1);
        DrawFormattedText(p.win, 'Dummy mode: press any key to start', 'center', 'center', p.text_colour)
        Screen('Flip', p.win);
        t.ts = Timestamp('Instruc press space onset', []);
        d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
        WaitSecs(1); % so you hopefully don't have keys down!
        KbWait();
        d.initTime=GetSecs();
        
    else
        DrawFormattedText(p.win, 'Waiting for scanner', 'center', 'center', p.text_colour)
        Screen('Flip', p.win);
        t.ts = Timestamp('Instruc wait TTL onset', []);
        d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
        
        % wait for first trigger scansync
        [pulse_time,~,daqstate] = scansync(1,Inf);
        d.initTime=GetSecs();
        
        t.ts = Timestamp('TR', []);
        d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
        
    end
    
    % --- do some instructions --- %
    
    t.ts = Timestamp(['Instructions ' d.procedure_type ' ' d.attended_feature], d.initTime);
    d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
    
    if p.procedure_index == 1
%         do_instructions(p,'first')
    end
    if strcmp(d.attended_feature,'colour')
        do_instructions(p,'colour')
    elseif strcmp(d.attended_feature,'size')
        do_instructions(p,'height')
    end
    if strcmp(d.procedure_type,'training')
        do_instructions(p,'training')
    else
        if p.practice
            do_instructions(p,'practice')
        else
            do_instructions(p,'test')
        end
    end
    
    % --- start procedure --- %
    
    t.ts = Timestamp(['Start of Procedure ' d.procedure_type ' ' d.attended_feature], d.initTime);
    d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
    
    %% block loop
    for block = 1:p.num_blocks
        fprintf('block %u of %u\n',block,p.num_blocks ); % report trial number to command window
        t.ts = Timestamp(['Start of Block  ' d.procedure_type ' ' d.attended_feature], d.initTime, block );
        d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
        % shuffle procedure
        d.procedure = NewShuffle(d.procedure,[2]); % shuffle rows independently on each page/third dimension (PTB shuffle (copied here as NewShuffle because one computer I was testing on had some old version?))
        %% trial loop
        t.lastresp = NaN(1,4); % initialise this
        for trial = 1:size(d.procedure,1)
            fprintf('trial %u of %u\n',trial,size(d.procedure,1)); % report trial number to command window
            t.ts = Timestamp(['Start of Trial ' d.procedure_type ' ' d.attended_feature], d.initTime, block, trial);
            d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
            t.this_trial = d.procedure(trial,:); % get the trial information
            t.this_stim_idx = t.this_trial(1); % get the index of the stimulus for the trial
            t.this_size = t.this_trial(2); % get the size of the trial
            if t.training
                if strcmp(t.training_type,'colour')
                    t.this_size = 2; % select medium size
                    t.stimulus = cell2mat(d.training_stimuli(find(strcmp(p.colours(t.this_stim_idx),d.training_stimuli(:,1))),2));
                    t.corr_colour = p.colours(t.this_stim_idx);
                elseif strcmp(t.training_type,'size')
                    t.stimulus = cell2mat(d.training_stimuli(find(strcmp(d.training_stimuli(:,1),'line')),2));
                end
            else
                t.stimulus = cell2mat(d.stimulus_matrix(t.this_stim_idx,2));
                t.corr_colour = d.stimulus_matrix(t.this_stim_idx,5);
            end
            
            % resize based on the size required
            t.stimulus = imresize(t.stimulus,p.size_scales(t.this_size));
            
            %             if you want to test
            % t.stimulus = cell2mat(d.stimulus_matrix(4,2));
            
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
            t.ts = Timestamp(['Cue Onset ' d.procedure_type ' ' d.attended_feature], d.initTime, block, trial);
            d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
            if p.vocal_stroop
                t.rt = getVoiceResponse(p.vocal_threshold, p.trial_duration, [save_file '_audio_' num2str(trial)], 'savemode', 2);
            elseif p.manual_stroop
                if ~p.buttonbox
                    WaitSecs(p.trial_duration); % wait for trial
                else
                    t.timenow = GetSecs;
                    [~,~,t.out] = scansync([],t.timenow+p.trial_duration);
                    t.thisresp = t.out.lastresp(2:5);
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
                    if any(t.thisresp)
                        if isequaln(t.lastresp,t.thisresp) % is equal, but with nans
                            t.pressed = 0;
                            t.resp_code = 0; % code invalid response
                            t.feedback = 'no valid response';
                            t.rt = NaN;
                        else
                            tmp1=t.thisresp;
                            tmp2=t.lastresp;
                            tmp1(isnan(t.thisresp)) = 0;
                            tmp2(isnan(t.lastresp)) = 0;
                            t.pressed = find(tmp1 ~= tmp2);
                            for iresult = 1:length(t.pressed)
                                t.pressed(2,iresult) = tmp1(t.pressed(1,iresult))-t.timenow;
                            end
                            t.first_press = t.pressed(1,find(t.pressed(2,:) == min(t.pressed(2,:))));
                            t.resp_code = t.first_press;
                            t.rt = min(t.pressed(2,:)); clear tmp1 tmp2;
                        end                
                    else
                        t.pressed = 0;
                        t.resp_code = 0; % code invalid response
                        t.feedback = 'no valid response';
                        t.rt = NaN;
                    end
                    t.lastresp = t.thisresp;
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
                if strcmp(d.attended_feature, 'size')
                    if t.this_size == t.resp_code
                        t.correct = 1;
                        t.feedback = 'correct';
                    else
                        t.correct = 0;
                        t.feedback = 'incorrect';
                    end
                elseif strcmp(d.attended_feature, 'colour')
                    if t.resp_code>0;
                        if strcmp(p.colours{t.resp_code},t.corr_colour)
                            t.correct = 1;
                            t.feedback = 'correct';
                        else
                            t.correct = 0;
                            t.feedback = 'incorrect';
                        end
                    else
                        t.correct = 0;
                        t.feedback = 'invalid';
                    end
                end
                t.ts = Timestamp(['Response ' d.procedure_type ' ' d.attended_feature], d.initTime, block, trial);
                d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
                
                if t.training || p.practice
                    % display trialwise feedback
                    DrawFormattedText(p.win, t.feedback, 'center', 'center', p.text_colour); % display feedback
                    Screen('Flip', p.win);
                    WaitSecs(p.trial_feedback_time);
                    Screen('Flip', p.win);
                end
                
            end % end manual stroop coding
            
            % collate the results
            d.results(trial,3,block) = {t.rt};
            if p.manual_stroop
                d.results(trial,4,block) = {t.correct};
            else
                d.results(trial,4,block) = {-2};
            end
            d.results(trial,5,block) = {t.this_stim_idx};
            d.results(trial,6,block) = {t.this_size};
            
            % end trial
            t.ts = Timestamp(['End of Trial ' d.procedure_type ' ' d.attended_feature], d.initTime, block, trial);
            d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
            
            %% post trial cleanup
            KbQueueRelease();
        end; clear trial;
        
        % do blockwise feedback
        if ~t.training && ~p.practice
            t.percent_correct = round((sum(cell2mat(d.results(:,4,block)))/length(cell2mat(d.results(:,4,block))))*100);
            t.pc_string = num2str(t.percent_correct);
            t.block_feedback = ['You got ' t.pc_string '% correct!'];
            % display trialwise feedback
            DrawFormattedText(p.win, t.block_feedback, 'center', 'center', p.text_colour); % display feedback
            Screen('Flip', p.win);
            WaitSecs(p.block_feedback_time);
            Screen('Flip', p.win);
        end
        
        save(save_file); % so we don't lose all data in a crash
        t.ts = Timestamp(['End of Block ' d.procedure_type ' ' d.attended_feature], d.initTime);
        d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
        
    end; clear block;
    save(save_file); % so we don't lose all data in a crash
    t.ts = Timestamp(['End of Procedure ' d.procedure_type ' ' d.attended_feature], d.initTime);
    d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
    
    
    %% wrap up
    
    save(save_file); % save the data
    
    t.ts = Timestamp('End experiment', []);
    d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
    
    % tell them it's over
    DrawFormattedText(p.win,'this run is done!', 'center', 'center', p.text_colour); % tell them it's over!
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
    Screen('CloseAll');
    rethrow(err);
end
