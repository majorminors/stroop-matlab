function [p,d] = Stroop(p,d,rootdir,stimdir,datadir)
fprintf('setting up %s\n', mfilename);

t = struct(); % another structure for untidy temp floating variables

% --- initial settings --- %
% rootdir = pwd; % root directory - used to inform directory mappings
% p.vocal_stroop = 0;
% p.manual_stroop = 1;
p.autoTrain = 1;

% --- tech settings --- %
p.testing_enabled = 0; % 1 will override some tech settings and replace with testing defaults (see defaults section)
p.scanning = 1;
p.tr = 1.208;
p.buttonbox = 1; % or keyboard
p.fullscreen_enabled = 0;
p.skip_synctests = 0; % skip ptb synctests
% p.ppi = 0; % will try to estimate with 0
p.screen_distance = 156.5; % cbu mri = 1565mm
p.screen_width = 69.84; % cbu mri = 698.4mm
p.resolution = [1920,1080]; % cbu mri = [1920,1080] (but not actual I think)
p.window_size = [0 0 1200 800]; % size of window when ~p.fullscreen_enabled

% block settings
p.num_blocks = 1; % overridden to training blocks for training and practice runs
p.num_training_blocks = 1; % will override num_blocks during training and practice

proc_scriptname = 'Procedure_Gen'; % name of script that generated stimulus and procedure matrices (appended as mfilename to participant savefile) - hasty workaround for abstracting this script

% keys
p.resp_keys = {'1!','2@','3#'}; % only accepts three response options
p.quitkey = {'q'}; % keep this for vocal and manual

% stimulus settings
tmpDist = 60; tmpPPU = 150/2.54; % old jsPsych distance and ppi->ppcm measurement
p.stim_heights = [... % in visual angle
    resizer(p,100,tmpDist,tmpPPU),...
    resizer(p,200,tmpDist,tmpPPU),...
    resizer(p,300,tmpDist,tmpPPU)]; clear tmpDist tmpPPU;
% convert this to angle with screen distance of jsPsych (50)
% not quite sure about this, but can do current ppi*stimHeightPixels/150 to
% convert
p.fixation_size = 40; % px
p.fixation_thickness = 4; % px
p.colours = {'red','blue','green'}; % used to create response coding, will assume stimulus file is named with correct colours
p.sizes = {'short','medium','tall'}; % used to create response coding (dont think this is actually used. maybe in a subfunction? Or maybe no longer need this)
p.vocal_threshold = 0.1; % between 0 and 1


% timing info
p.iti_time = 0.3; % inter trial inteval time
p.trial_duration = 1.5; % seconds for the stimuli to be displayed
p.trial_feedback_time = 0.5; % period to display feedback after response
p.block_feedback_time = 1; % period to display feedback after block

% --- some checks --- %
if p.vocal_stroop && p.manual_stroop; error('you cannot do both vocal and manual stroop'); end
if ~p.buttonbox && p.scanning; error('you probably dont want to scan without the button box'); end

%-------------------%
% directory mapping %
%-------------------%

%if ispc; setenv('PATH',[getenv('PATH') ';C:\Program Files\MATLAB\R2018a\toolbox\CBSU\Psychtoolbox\3.0.14\PsychContributed\x64']); end % make sure psychtoolbox has all it's stuff on cbu pc
% addpath(genpath(fullfile(rootdir, 'lib'))); % add tools folder to path
% stimdir = fullfile(rootdir, 'lib', 'stimuli');
% datadir = fullfile(rootdir, 'data'); % will make a data directory if none exists
% if ~exist(datadir,'dir'); mkdir(datadir); end

%----------%
% defaults %
%----------%

KbName('UnifyKeyNames'); % makes key mappings compatible (mac/win)
rng('shuffle'); % seed rng using date and time

% testing setup
if p.testing_enabled == 1
    p.PTBsynctests = 1; % PTB will skip synctests if 1
    p.PTBverbosity = 1; % PTB will only display critical warnings with 1
    Screen('Preference', 'ConserveVRAM', 64); % for working on a vm, we need this enabled
    p.scanning = 0;
    p.buttonbox = 0; % or keyboard
    p.fullscreen_enabled = 0;
    p.window_size = [0 0 1200 800]; % size of window when ~p.fullscreen_enabled
elseif p.testing_enabled == 0
    if p.skip_synctests
        p.PTBsynctests = 1;
    elseif ~p.skip_synctests
        p.PTBsynctests = 0;
    end
    p.PTBverbosity = 3; % default verbosity for PTB
end

% --- psychtoolbox setup --- %
AssertOpenGL; % check Psychtoolbox (on OpenGL) and Screen() is working

Screen('Preference', 'SkipSyncTests', p.PTBsynctests);
Screen('Preference', 'Verbosity', p.PTBverbosity);
if p.vocal_stroop
    InitializePsychSound;
    PsychPortAudio('Verbosity', 3);
    % open the default audio device
    p.pahandle    = PsychPortAudio('Open', [], 2, 0, 44100, 2);
end

% --- screen stuff --- %

% get the screen numbers
p.screens = Screen('Screens'); % funny difference pc to other oses, but doesn't matter in cbu fMRI

% draw to the external screen if available
p.screen_num = max(p.screens);

p.size_scales = {... %  will feed imresize [rows (i.e. y pixels),cols (i.e. x pixels)] - NaNs mean auto (i.e. maintain aspect ratio
    [angle2pix(p,p.stim_heights(1)),NaN],...
    [angle2pix(p,p.stim_heights(2)),NaN],...
    [angle2pix(p,p.stim_heights(3)),NaN]};

p.black = BlackIndex(p.screen_num); % essentially [0 0 0]
p.white = WhiteIndex(p.screen_num);
p.grey = p.white / 2; % essentially [255/2 255/2 255/2]
p.bg_colour = p.grey;
p.text_colour = p.black; % colour of instructional text
p.text_size = 40; % size of text

%-------------------%
% participant setup %
%-------------------%

% set up participant info and save
% t.prompt = {'enter participant number:',...
%     'enter run/procedure number:',...
%     'is this a practice run? (1 or 0 + overridden during training)'}; % prompt a dialog to enter subject info
% t.prompt_defaultans = {num2str(99),num2str(1),num2str(1)}; % default answers corresponding to prompts
% t.prompt_rsp = inputdlg(t.prompt, 'enter participant info', 1, t.prompt_defaultans); % save dialog responses
% d.participant_id = str2double(t.prompt_rsp{1}); % add subject number to 'd'
% p.procedure_index = str2double(t.prompt_rsp{2}); % add the procedure index, so we can pull the trials from the procedure matrix later
% p.practice = str2double(t.prompt_rsp{3});
% 
% % check participant info has been entered correctly for the script
% if isnan(d.participant_id); error('no participant number entered'); end

% code for save structure
if p.vocal_stroop; t.exp_type = 'vocal'; elseif p.manual_stroop; t.exp_type = 'manual'; end

% search for a savedir (where the procedure file should be)
if ~exist(fullfile(datadir,t.exp_type),'dir'); error('no experiment type directory, have you chosen the right experiment type?'); end
savedir = fullfile(datadir,t.exp_type,num2str(d.participant_id,'S%02d')); % will error if none exists
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
d.stimulus_type = t.procedure_code{2};

% do a lil check

disp('procedure list: ');
disp(d.all_procedure_codes);
fprintf('you chose procedure %1.0f\n',p.procedure_index);
fprintf('stimulus type: %s\n',d.stimulus_type);
fprintf('with attended feature: %s\n',d.attended_feature);
if p.practice || strcmp(d.stimulus_type,'training')
    t.est_mins = (p.num_training_blocks*size(d.procedure,1)*(p.iti_time+p.trial_duration))/60; % (blocks*trials*(iti time + trial time))/60 - estimated mins
else
    t.est_mins = (p.num_blocks*size(d.procedure,1)*(p.iti_time+p.trial_duration))/60; % (blocks*trials*(iti time + trial time))/60 - estimated mins
end
disp('you are saving into folder with contents:')
ls([savedir,filesep,'*.mat']);
if p.autoTrain
    warning(sprintf([
        'you are autotraining\n',...
        'we will automatically do training and practice trials\n',...
        'this assumes existing save files for this procedure are practices and overwrites them']));
end
fprintf('this will take about %1.0f mins (not accounting for feedback or loading)\n\n',t.est_mins);

t.prompt = 'look right ([y]/n)?  ';
t.ok = input(t.prompt,'s');
if isempty(t.ok); t.ok = 'y'; end
if ~strcmp(t.ok,'y'); error('no good'); end

try
    %----------%
    % commence %
    %----------%
    
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
    
    
    % --- autotraining loop! --- %
    t.scanning = p.scanning; % we'll use this so we can change it in the loop
    doProcedures = 1;
    forcePractice = 0;
    while doProcedures % a while loop so we can automatically do training/prac runs
        
        if p.autoTrain
            
            % --- pull all this again, because the idx will change now dynamically --- %
            d.procedure = d.all_procedures(:,:,p.procedure_index);
            t.procedure_code = d.all_procedure_codes(p.procedure_index,:);
            d.attended_feature = t.procedure_code{1};
            d.stimulus_type = t.procedure_code{2};
            
            if strcmp(d.stimulus_type,'training') % if current procedure is training
                doProcedures = doProcedures+1;
                p.procedure_index = p.procedure_index+1;
            elseif p.procedure_index > 1
                % if previous procedure was training (i.e. this one will be a practice)
                if strcmp(d.all_procedure_codes{p.procedure_index-1,2},'training')
                    doProcedures = doProcedures+1;
                    forcePractice = 1; % will only matter if there isn't a save file
                end
            end
        end
        
        % --- create a save file name --- %
        
        save_file_name = [num2str(d.participant_id,'S%02d'),'_',t.exp_type,'_',mfilename,'_',d.attended_feature,'_',d.stimulus_type];
        save_file = fullfile(savedir, save_file_name);
        if exist([save_file '.mat'],'file') % check if the file already exists to do stuff
            p.practice = 0; % you might have already practiced
            if ~strcmp(d.stimulus_type,'training')
                doProcedures = 1;
            end
        elseif forcePractice
            p.practice = 1;
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
        d.results(:,2,:) = {d.stimulus_type};
        % 3) rt
        % 4) correct (meaningful only for manual, otherwise -2)
        % 5) stimulus index (to get from d.stimulus_matrix the stimulus information)
        
        
        % --- do some edits based on practice/training --- %
        
        if strcmp(d.stimulus_type,'training') % if it's a training trial
            disp('training procedure')
            t.training = 1;
            if p.scanning == 1; warning('you had p.scanning on, but this is a training block so im going to turn it off');t.scanning = 0; end
            t.training_type = d.attended_feature; % we're going to use a more legible name for this
            t.num_blocks = p.num_training_blocks; % override num blocks
            d.results(:,:,2:end) = []; % delete the extra dimensions - only one for training
        else
            t.training = 0;
            if p.practice
                t.num_blocks = p.num_training_blocks; % override num blocks
                if p.scanning == 1; warning('you had p.scanning on, but this is a practice block so im going to turn it off');t.scanning = 0; end
                d.results(:,:,2:end) = []; % delete the extra dimensions - only one for training
            else % set to experimental parameters
                t.scanning = p.scanning;
                t.num_blocks = p.num_blocks;
            end
        end
        
        % -- AW 23/8/19, wait for experimenter (wil PA blib is running) --
        DrawFormattedText(p.win, 'Experimenter: start run when ready', 'center', 'center', p.text_colour);
        Screen('Flip', p.win);
        t.ts = Timestamp('Instruc press space onset', []);
        d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
        WaitSecs(1); % so you hopefully don't have keys down!
        KbWait();
        
        
        % --- set fMRI parameters --- %
        if t.scanning || p.buttonbox
            % Initialise a scansync session
            scansync('reset',p.tr);         % also needed to record button box responses
        end
        
        
        % --- wait until TTL (this is after 4 dummy scans) ---
        if ~t.scanning %msg experimenter
            WaitSecs(0.1);
            DrawFormattedText(p.win, 'Dummy mode: press any key to start', 'center', 'center', p.text_colour);
            Screen('Flip', p.win);
            t.ts = Timestamp('Instruc press space onset', []);
            d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
            WaitSecs(1); % so you hopefully don't have keys down!
            KbWait();
            d.initTime=GetSecs();
            
        else
            DrawFormattedText(p.win, 'Waiting for scanner', 'center', 'center', p.text_colour);
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
        
        t.ts = Timestamp(['Instructions ' d.stimulus_type ' ' d.attended_feature], d.initTime);
        d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
        
        if p.procedure_index == 1
            %         do_instructions(p,'first')
        end
        if strcmp(d.attended_feature,'colour')
            do_instructions(p,'colour')
        elseif strcmp(d.attended_feature,'size')
            do_instructions(p,'height')
        end
        if strcmp(d.stimulus_type,'training')
            do_instructions(p,'training')
        else
            if p.practice
                do_instructions(p,'practice')
            else
                do_instructions(p,'test')
            end
        end
        
        % --- start procedure --- %
        
        t.ts = Timestamp(['Start of Procedure ' d.stimulus_type ' ' d.attended_feature], d.initTime);
        d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
        
        %% block loop
        for block = 1:t.num_blocks
            fprintf('block %u of %u\n',block,t.num_blocks ); % report trial number to command window
            t.ts = Timestamp(['Start of Block  ' d.stimulus_type ' ' d.attended_feature], d.initTime, block );
            d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
            % shuffle procedure
            d.procedure = NewShuffle(d.procedure,[2]); % shuffle rows independently on each page/third dimension (PTB shuffle (copied here as NewShuffle because one computer I was testing on had some old version?))
            %% trial loop
            t.lastresp = NaN(1,4); % initialise this
            for trial = 1:size(d.procedure,1)
                tic;disp('trial setup')
                if trial == 1; WaitSecs(1); end % just put a bit of space between whatever happened before the first trial

                fprintf('trial %u of %u\n',trial,size(d.procedure,1)); % report trial number to command window
                t.ts = Timestamp(['Start of Trial ' d.stimulus_type ' ' d.attended_feature], d.initTime, block, trial);
                d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure


                t.this_trial = d.procedure(trial,:); % get the trial information
                t.this_stim_idx = t.this_trial(1); % get the index of the stimulus for the trial
                t.this_size = t.this_trial(2); % get the size of the trial
                t.corr_size = p.sizes{t.this_size};
                if t.training
                    if strcmp(t.training_type,'colour')
                        t.this_size = 2; % select medium size
                        t.stimulus = cell2mat(d.training_stimuli(find(strcmp(p.colours(t.this_stim_idx),d.training_stimuli(:,1))),2));
                        t.corr_colour = cell2mat(p.colours(t.this_stim_idx));
                    elseif strcmp(t.training_type,'size')
                        t.stimulus = cell2mat(d.training_stimuli(find(strcmp(d.training_stimuli(:,1),'line')),2));
                    end
                else
                    t.stimulus = cell2mat(d.stimulus_matrix(t.this_stim_idx,2));
                    t.corr_colour = cell2mat(d.stimulus_matrix(t.this_stim_idx,5));
                end
                
                % resize based on the size required
                t.stimulus = imresize(t.stimulus,p.size_scales{t.this_size});
                
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
                
                toc
                
                tic;disp('fixation/iti')
                Screen('DrawLines', p.win, p.allCoords, p.fixation_thickness, p.text_colour, [p.xCenter p.yCenter], 2);
                Screen('Flip', p.win);
                WaitSecs(p.iti_time);
                toc
                % make the texture and draw it
                tic;disp('texture for image')
                t.stim_tex = Screen('MakeTexture', p.win, t.stimulus);
                Screen('DrawTexture', p.win, t.stim_tex); % draws the cue
                toc
                % then display cue
                tic;disp('cue onset timestamp')
                t.cue_onset = Screen('Flip', p.win); % pull the time of the screen flip from the flip function while flipping
                t.ts = Timestamp(['Cue Onset ' d.stimulus_type ' ' d.attended_feature], d.initTime, block, trial);
                d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
                toc
                if p.vocal_stroop
                    t.rt = getVoiceResponse(p.vocal_threshold, p.trial_duration, [save_file '_audio_' num2str(trial)], p.pahandle, 'savemode', 2);
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
                tic;disp('post trial actions')
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
                    t.ts = Timestamp(['Response ' d.stimulus_type ' ' d.attended_feature], d.initTime, block, trial);
                    d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
                    
                end % end manual stroop coding

                if p.vocal_stroop % create feedback
                    if strcmp(d.attended_feature, 'size')
                        t.vocal_ans = t.corr_size;
                    elseif strcmp(d.attended_feature, 'colour')
                        t.vocal_ans = t.corr_colour;
                    end
                    t.feedback = ['correct answer was ',t.vocal_ans];
                end
                
                if t.training || p.practice
                    % display trialwise feedback
                    DrawFormattedText(p.win, t.feedback, 'center', 'center', p.text_colour); % display feedback
                    Screen('Flip', p.win);
                    WaitSecs(p.trial_feedback_time);
                    Screen('Flip', p.win);
                end

                
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
                t.ts = Timestamp(['End of Trial ' d.stimulus_type ' ' d.attended_feature], d.initTime, block, trial);
                d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure

                %% post trial cleanup
                KbQueueRelease();
                toc
            end; clear trial;
            
            % do blockwise feedback
            if ~t.training && ~p.practice && ~p.vocal_stroop
                t.percent_correct = round((sum(cell2mat(d.results(:,4,block)))/length(cell2mat(d.results(:,4,block))))*100);
                t.pc_string = num2str(t.percent_correct);
                t.block_feedback = ['You got ' t.pc_string '% correct!'];
                % display feedback
                DrawFormattedText(p.win, t.block_feedback, 'center', 'center', p.text_colour); % display feedback
                Screen('Flip', p.win);
                WaitSecs(p.block_feedback_time);
                Screen('Flip', p.win);
            end
            
            save(save_file); % so we don't lose all data in a crash
            t.ts = Timestamp(['End of Block ' d.stimulus_type ' ' d.attended_feature], d.initTime);
            d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
            
        end; clear block;
        save(save_file); % so we don't lose all data in a crash
        t.ts = Timestamp(['End of Procedure ' d.stimulus_type ' ' d.attended_feature], d.initTime);
        d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
        
        
        %% wrap up
        
        save(save_file); % save the data
        
        t.ts = Timestamp('End experiment', []);
        d.timestamps = [d.timestamps,t.ts]; % concatenate the timestamp to the timestamp structure
        
        doProcedures = doProcedures-1; %deiterate
    end % end autotrain while loop
    
    if p.vocal_stroop
        %% Close the audio device:
        PsychPortAudio('Close', p.pahandle);
    end
    
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
    KbQueueRelease(); % so we don't get warnings with listenchar etc
    if p.vocal_stroop;PsychPortAudio('Close', p.pahandle);end
    ShowCursor;
    Screen('CloseAll');
    rethrow(err);
end

return
end