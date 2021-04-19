%%fMRI Localiser for colour ROI%%
%%12.03.2017 Jade Jackson%%

clear all;
% Screen('Preference', 'ConserveVRAM', 64)

%% Disables Synchronisation %% Comment out for testing
Screen('Preference', 'SkipSyncTests', 1);

% choose stroop type (will save in data>saveFolderName>participant #)
saveFolderName = 'manual';


%% Are we scanning??
scannerstart=1;  %%% Change for scanning session
ButtonBoxOn=1; % if button box is being used with scansync

%% Task Parameters
grey =[128 128 128]; black = [0 0 0]; white = [255 255 255]; %%Colours
Cue1 = 'TASK: FIND THE DOT';

%%Trials/Blocks/Runs
TotalTrials = 30; TotalBlocks = 40;

%%Input && Ordering
subjectnostr = input('Subject Number?: ','s');
subjectno = str2num(subjectnostr); %%convert to number from string

if mod(subjectno,2) == 1 %odd %Evaluate if subject and counterbalance numbers are even or odd
    subjectisodd = 1;
elseif mod(subjectno,2) == 0 %even
    subjectisodd = 0;
else error('Cant evaluate subject number??');
end

%%Presentation of task%%
if subjectisodd
    ContextCueOrder= repmat([1,2],1,24); %%presentation of task context
else
    ContextCueOrder=repmat([2,1],1,24); %%presentation of task context
end

maindir = pwd; %%main directory
addpath(genpath(fullfile(maindir,'lib'))); % add lib path
% search for a savedir (where the procedure file should be)
if ~exist(fullfile(maindir,'data',saveFolderName),'dir'); error('no experiment type (saveFolderName) directory, have you chosen the right experiment type?'); end
outdir = fullfile(maindir,'data',saveFolderName,num2str(subjectno,'S%02d'));
if ~exist(outdir,'dir'); error('no save directory for this participant, have you run the procedure generator?'); end
outfile = fullfile(outdir, ['ColLocaliser.txt']); %%file name
fid = fopen(outfile,'a');
if exist(outfile) %Print Error if Outfile Exists
    disp('WARNING: OUTPUT FILE EXISTS'); %Screen('CloseAll')
end
stimdir = fullfile(maindir,'lib','ColourLocaliserStimuli');

%%Screen Parameters & Main Parameters
[Win, Rect] = Screen('OpenWindow', 0, grey,[]); %%actual
%[Win, Rect] = Screen('OpenWindow', 0, black, [0 0 400 400]); %testing
Screen('Flip',Win); %%flip on window
HideCursor;%%hide mouse
center = [Rect(3)/2, Rect(4)/2]; %%centre of screen
centRect10=[0 0 1920 1080]; %%entire size of screen (CHANGE FOR SCANNER)
FixationCross = [0,0,-15,15;15,-15,0,0]; %%cross
FixationCrossBg = [0,0,-17,17;17,-17,0,0];
SizeOval = CenterRect([0 0 6 6], Rect); %%size of circle for passive condition

% start with TTL pulse
keyCode=zeros(255,1); %%clear the keyboard responses

if scannerstart %% do we want the scanner if so then set to 1 earlier?
    TR = 1.208;                  % TR in s % CHANGE THIS LINE
    % Initialise a scansync session
    scansync('reset',TR);         % also needed to record button box responses
    DrawFormattedText(Win, 'Waiting for scanner', 'center', 'center', white)
    Screen('Flip', Win);
    
    % wait for first trigger scansync
    [pulse_time,~,daqstate] = scansync(1,Inf);
    initTime=GetSecs();
else
    initTime=GetSecs; %%timestamp
end

%Keyboard and Button Box Responses
% key=[66 89]; %for button box 'b' 'y'

%%Instructions
Screen('TextSize', Win, 41);
TextToPut = Cue1;
DrawFormattedText(Win, TextToPut, 'center','center',white);
Screen('Flip',Win); %%flip on
if ButtonBoxOn % wait for participant keypress
    scansync([2:5],Inf);
else
    KbWait();
end
Screen('Flip',Win); %%flip off

%%START OF BLOCK LOOP%%
for block = 1:TotalBlocks
    BlockTime=GetSecs-initTime; %%Timestamp
%     if block > 1
%         Screen('DrawLines', Win, FixationCross, 4, white, center);
%         Screen('Flip',Win); WaitSecs(3); Screen('Flip',Win) %%off
%     end
    
    %%Make a vector of the possible trial conditions
    TrialList = []; %% Clear previous block variable
    n=16; %conditions: ROPE x 8 and GIFT x 4 and BAND x 4
    a=zeros(2,n);%%create empty matrix
    for i=1:2;
        a(i,:) = randperm(n);
    end;
    vector1 = reshape(a.',[],1);
    TrialList=vector1'; %%RandomVectorOfTrialOrderRenewedEachBlock
    DotsOccur = randperm(30,5); %%trials for dots to occur randomly
    
    CurrentCue=ContextCueOrder(block); %%Get current task
    if CurrentCue == 1
        BlockCondition = 'Colour'; Directory = fullfile(stimdir,'Colour'); %%where to find images
    elseif CurrentCue == 2
        BlockCondition = 'Greyscale'; Directory = fullfile(stimdir,'Grey'); %%where to find images
    end
    
    for trial = 1:TotalTrials
        Screen('DrawLines', Win, FixationCross, 4, white, center); %%draw fixation cross
        Screen('Flip',Win);
        if trial == 1; WaitSecs(1); end % just put a bit of space between whatever happened before the first trial
        TrialStart=GetSecs-initTime; %%Timestamp
        offsetValue1 = []; offsetValue1 =randi([-250 250]); %%movement of square x
        offsetValue2 = []; offsetValue2 = randi([-250 250]); %%movement of square y
        newRect = []; newRect = OffsetRect(SizeOval,offsetValue1,offsetValue2); %%Rect for oval block 3
        
        %%Break out of Loop if need to with keyboardbutton 'q'
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        if keyIsDown;
            if strcmp(KbName(keyCode),'q');
                Screen('CloseAll');
                return
            end
        end
        
        Stimulus=TrialList(trial); %%stimulus number for this trial
        StrStim = num2str(Stimulus); %%change to string
        Image= fullfile(Directory, [StrStim '.jpg']); %%find stimulus for this trial
        ImageTexture=Screen('MakeTexture', Win, imread(Image)); %%make image texture
        Screen('DrawTextures', Win, ImageTexture, [],centRect10); %%draw image
        Screen('DrawLines', Win, FixationCrossBg, 8, white/2, center); %%draw gray fixation cross
        Screen('DrawLines', Win, FixationCross, 4, white, center); %%draw gray fixation cross
        
        if intersect(trial,DotsOccur)
            Screen('FillOval',Win,white,newRect); %%if dot trial then make dot
            Dot = 'Yes'; %%are there dots?... write to file
            Screen('Flip',Win); StimTimeOn=GetSecs-initTime;
            if ButtonBoxOn
                [~,~,all_buttons_pressed] = buttonboxWaiter(0.5); % this seems dangerous - how much do we care about buttonpresses? 
                aButtonPressed = any(all_buttons_pressed);
            else
                aButtonPressed = -1;WaitSecs(0.5);
            end
            %WaitSecs(0.5); 
            Screen('Flip',Win); StimTimeOff=GetSecs-initTime;
        else
            Screen('Flip',Win); StimTimeOn=GetSecs-initTime;
            if ButtonBoxOn
                [~,~,all_buttons_pressed] = buttonboxWaiter(0.5); % this seems dangerous - how much do we care about buttonpresses? 
                aButtonPressed = any(all_buttons_pressed);
            else
                aButtonPressed = -1;WaitSecs(0.5);
            end
            %WaitSecs(0.5); 
            Screen('Flip',Win); StimTimeOff=GetSecs-initTime;
            Dot = 'No'; %%are there dots write to file
        end

        TrialEnd=GetSecs-initTime; %%Timestamp

        fprintf(fid,'%s \t %d \t %s \t %f \t %s \t %f \t %s \t %s \t %s \t %f \t %s \t %d \t %s \t %f \t %s \t %f \t %s \t %s \t %s \t %s \t %s \t %f \t %s \t %f \t %s \t %f \t \n',...
            'Subject',subjectno,'InitialTime', initTime,'BlockNumber',block,'BlockCondition',BlockCondition,'BlockTime',BlockTime,'TrialNumber',trial,'TrialTime',TrialStart,'TrialEnd',TrialEnd,'ImageNumber',StrStim,'Dot',Dot,'StimulusOn',StimTimeOn,'StimulusOff',StimTimeOff,'ButtonPressed',aButtonPressed);
        
    end %%end trial loop
    
end %%end block loop

Screen('CloseAll')
