%% Stroop task procedure generator
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
p.max_height = 600; % in rows for the largest size scale of images
p.vocal_stroop = 0;
p.manual_stroop = 1;

% directory mapping
addpath(genpath(fullfile(rootdir, 'lib'))); % add tools folder to path (includes moving_dots function which is required for dot motion, as well as an external copy of subfunctions for backwards compatibility with MATLAB)
stimdir = fullfile(rootdir, 'lib', 'stimuli');
datadir = fullfile(rootdir, 'data'); % will make a data directory if none exists
if ~exist(datadir,'dir'); mkdir(datadir); end

% set up participant info and save
t.prompt = {'enter participant number:'}; % prompt a dialog to enter subject info
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

save(save_file); % save all data to a .mat file

disp('done')
