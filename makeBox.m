
rootdir = pwd; % root directory - used to inform directory mappings
addpath(genpath(fullfile(rootdir, 'lib'))); % add tools folder to path

p.screen_distance = 156.5; % cbu mri = 1565mm
p.screen_width = 69.84; % cbu mri = 698.4mm
p.resolution = [1920,1080]; % cbu mri = [1920,1080] (but not actual I think)
p.window_size = [0 0 1200 800]; % size of window when ~p.fullscreen_enabled
p.fullscreen_enabled = 1;

% stimulus settings
boxSize = 100;
thisPPU = p.resolution(1)/p.screen_width;
boxResize = thisPPU*boxSize/150;

% convert this to angle with screen distance of jsPsych (50)
% not quite sure about this, but can do current ppi*stimHeightPixels/150 to

% --- screen stuff --- %

Screen('Preference', 'SkipSyncTests', 1);

% get the screen numbers
p.screens = Screen('Screens'); % funny difference pc to other oses, but doesn't matter in cbu fMRI

% draw to the external screen if available
p.screen_num = max(p.screens);

p.black = BlackIndex(p.screen_num); % essentially [0 0 0]
p.white = WhiteIndex(p.screen_num);
p.grey = p.white / 2; % essentially [255/2 255/2 255/2]
p.bg_colour = p.grey;
p.text_colour = p.black; % colour of instructional text
p.text_size = 40; % size of text

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
    ListenChar(2);
    WaitSecs(0.5); % warm up

    baseRect = [0 0 boxResize boxResize];
    centeredRect = CenterRectOnPointd(baseRect, p.xCenter, p.yCenter);
    rectColor = [1 0 0];
    
    Screen('FillRect', p.win, rectColor, centeredRect);
    
    % then display cue
    t.cue_onset = Screen('Flip', p.win); % pull the time of the screen flip from the flip function while flipping

    KbWait();
    
    % close screen
    ShowCursor;
    clear ans; % clear extraneous stuff
    Screen('Close',p.win);
    ListenChar(0);
    
    fprintf('done running %s\n', mfilename);
    
catch err
    ShowCursor;
    ListenChar(0);
    Screen('CloseAll');
    rethrow(err);
end
