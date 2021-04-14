% run PerceptualVBLSyncTest to check the timing first

function GenerativeVisual()
    % Clear the workspace and the screen
    KbName('UnifyKeyNames'); 
    close all;
    clear all;
    sca
try
    % Enclose all your real code between try and catch.
    
    % Removes the blue screen flash and minimize extraneous warnings.
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
    
    % Find out how many screens and use largest screen number.
    whichScreen = max(Screen('Screens'));
    
    
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    Screen('OpenWindow', whichScreen);
 %   error('Oops!');
    
    % Clean up, although in this case we never get here.
    Screen('CloseAll');
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    
    % If I'd been doing this in any other language I'd parse the input
    % so as to be able to pick up new parameters and change the text displayed
    % between blocks etc
    
   
    
    
    
    % This doesn't do anything to ensure that timing is synced with refresh.
    % Fortunately there's nothing critical that depends on controlling WHEN the
    % stims should be displayed, so long as we know when it happens.
    % Even that probably doesn't matter much relative to the errors in
    % using a voice-key.
    
    % see http://peterscarfe.com/accurateTimingDemo.html
    % Measure the vertical refresh rate of the monitor
    % ifi = Screen('GetFlipInterval', window);
    
    % Typing 'Screen' in MATLAB gives this:
    
    % [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', windowPtr [, when] [, dontclear] [, dontsync] [, multiflip]);
    
    % which isn't helpful without a better description of the arguments and
    % the units.
    
    
    % The voice key bit works with the Focusrite Scarlet 2i2 so long as the
    % focusrite driver is used, but I don't know how good the timing is
    % likely to be. BEWARE - if the focusrite isn't set up to be the input
    % it hangs. The only fix seems to be to set it up in Audition, and this
    % seems to require the Focusrite to be unplugged/replugged.
    % Also works with the Sennheiser usb headset.
    %
    % https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/topics/109
    % 29
    % DrawMirroredTextDemo([upsideDown=0])
    % _______________________________________________________
    %
    %  Trivial example of drawing mirrored text. This demonstrates how to use
    %  low-level OpenGL API functions to apply geometric transformations to
    %  the drawn objects.
    %
    %  Will draw a text string, once in normal orientation, and once mirrored.
    %  The mirrored text is either mirrored left<->right, or upside down if you
    %  set the optional 'upsideDown' flag to 1. At each key press, the text
    %  will be redrawn at an increasing size, until after a couple of redraws
    %  the demo will end.
    %
    %  The demo also draws a bounding box around the text string to demonstrate
    %  how you can find out about the bounds of a text string via
    %  Screen('TextBounds').
    %
    %  The mirroring is implemented by first defining a geomtric transformation
    %  which will apply to all further drawn shapes and text strings. Then the
    %  text string is drawn via Screen('DrawText') -- thereby affected by the
    %  geometric transform. Then the transform is undone to "normal".
    %
    %  How does this work?
    %
    %  1. The command Screen('glPushMatrix'); makes a "backup copy" of the
    %  current transformation state -- the default way of drawing.
    %
    %  2. The command Screen('glTranslate', w, xc, yc, 0); translates the
    %  origin of the coordinate system (which is normally located at the
    %  upper-left corner of the screen) into the geometric center of the
    %  location of the text string. We find the center xc,yc by retrieving the
    %  bounding box of the text string Screen('TextBounds'), then calculating
    %  the center of that box [xc, yc].
    %
    %  3. The Screen('glScale', w, x, y, z); will scale all further drawn
    %  objects by a factor 'x' in x-direction (horizontal), 'y' in y-direction
    %  (vertical), 'z' in z-direction (depths). Scaling happen with respect to
    %  the current origin. As we just set the origin to be the center of the
    %  text string in step 2, the object will "scale" around that point. A
    %  value of -1 effectively switches the direction along the 'x' axis for a
    %  horizontal flip, or along the 'y' axis for an upside down vertical flip.
    %  Values with a magnitude other than 1 would scale the whole text up or
    %  down in size.
    %
    %  4. The command Screen('glTranslate', w, -xc, -yc, 0); translates the
    %  origin of the coordinate system back to the upper-left corner of the
    %  screen. This to make sure that all coordinates provided later on are
    %  wrt. to the usual reference frame.
    %
    %  Steps 2,3 and 4 are internally merged to one mathematical transformation:
    %  The flipping of all drawn shapes and objects around the screen position
    %  [xc,yc] -- the center of the text string.
    %
    %  5. We Screen('DrawText') the text string --> The flipping applies.
    %
    %  6. We undo the whole transformation via Screen('glPopMatrix') thereby
    %  restoring the original "do nothing" transformation from the backup copy
    %  which was created in step 1. All further drawing is therbey unaffected
    %  by the flipping, so we can draw the second copy of the text and the
    %  bounding box.
    %
    % Besides the scaling and translation transform for moving, rescaling and
    % flipping drawn objects and shapes, there is also the Screen('glRotate')
    % transform to apply rotation around axis.
    %
    % This transformations apply to any drawing command, not only text strings!
    % _________________________________________________________________________
    %
    % see also: PsychDemos
    
    % 3/8/04    awi     Wrote it.
    % 7/13/04   awi     Added comments section.
    % 9/8/04    awi     Added Try/Catch, cosmetic changes to documentation.
    % 11/1/05   mk      Derived from DrawSomeTextOSX.
    
    
    params.targetFont = 'Arial';
    params.targetFontSize = 40;
    params.maskFont =  'Adobe Myungjo Std M';
    params.maskFontSize = 50;
    params.primeFont = 'Arial';
    params.primeFontSize = 40;
    params.messageFontSize = 24;
    params.primeDuration = 1; %  duration of pre-mask. Durations are all in secs
    params.fastMask = 0.5;
    params.slowMask = 2.0;
    params.targetDuration = 0.25;
    params.fixationDuration = 2.0;
    params.primeTargetISI = 0;
    params.voiceKeyWindow = 3.0;
    params.readyText =  'press any key to continue';
    params.endOfBlockText = 'take a break';
    params.fixationText = '+';
    params.nTrialsInBlock = 20;
    params.nPracticeTrials = 10;
    params.nTrialsTotal = 0; % just gets set by the number of lines in the stim file
    params.freq = 11025;  % audio sampling freq
    params.audioDir = ''; % where we're storing the voice key recordings
    params.centre_x = 0; % coords for centre of screen
    params.centre_y = 0;
    params.allaudiodata = zeros((params.voiceKeyWindow  + 10) * params.freq,1); % buffer to concatenate successive chunks of audio into
                                                  % this will contain the
                                                  % recorded speech
                                                   % I've whacked this up to over 10s to avoid any possibility of not
                                                    % draining the buffer in time. I really don't think this was the cause of the failure to collect
                                                    % audiodata as I never got it to crash even when I never responded. 18-8-2015
    %trialStruct(1).RT = -999;
    
    % SEE http://peterscarfe.com/accurateTimingDemo.html
    
    % get the stimulus file using the ui dialogue
    try
        stimFilename = sprintf('%s/*.txt',pwd);
        %fprintf('about to get: %s\n', stimFilename);
        [stimFilename,PathName] = uigetfile(stimFilename,'Select stimulus file:');
    catch
        fprintf('Error opening %s\n',stimFilename);
        Screen('CloseAll');
        fclose('all');
        psychrethrow(psychlasterror);
    end
    
    
    try
        [params.dataFilename,dataPathName] = uiputfile('*.csv','Data filename:',PathName);
        params.dataFilename = sprintf('%s/%s',dataPathName,params.dataFilename);
        params.dataFileID = fopen(params.dataFilename,'w');
        fprintf('data file name is: %s\n', params.dataFilename);
    catch
        fprintf('Error opening %s\n',params.dataFilename);
        Screen('CloseAll');
        fclose('all');
        psychrethrow(psychlasterror);
    end
    
    
    try
        % textread is a pain because things come in as cell arrays, so later we
        % have to convert them to strings.
        [stimData.group, stimData.zeno, stimData.words, stimData.nonwords, stimData.targets, stimData.status, stimData.speed] = textread(stimFilename,'%s %d %s %s %s %s %s');
        ntrials = length(stimData.targets);
    catch
        fprintf('Error reading %s\n',stimFilename);
        Screen('CloseAll');
        fclose('all');
        psychrethrow(psychlasterror);
    end
    
    
    % Now make a directory to store the audio in. If the data file is s21.csv
    % the dir will be s21 and the audio files will all be called trial_mask_target.wav
    try
        [pathstr,name,ext] = fileparts(params.dataFilename);
        params.audioDir = sprintf('%s/%s',pathstr,name);
        mkdir(params.audioDir);
        
    catch
        fprintf('Error making directory for audio files %s\n',params.audioDir);
        Screen('CloseAll');
        fclose('all');
        psychrethrow(psychlasterror);
    end
    
    
    
    
    % Here we call some default settings for setting up Psychtoolbox
    PsychDefaultSetup(2);
    
    % surely there's a better way of initialising things?
    params.nTrialsTotal = ntrials;
    trialStruct(ntrials).RT = -99;  % MATLAB has a strange way of allocation arays of structs
    trialStruct(ntrials).audioRT = -99; %
    trialStruct(1).error = -99;     % the other fields need to exist
    trialStruct(1).condition = '';
    trialStruct(1).speed = '';
    trialStruct(1).target = '';
    trialStruct(1).mask = '';
    trialStruct(1).group = '';
    
    
    
    % order = randperm(ntrials); % the input files are now ordered
    %targets=targets(order); % FIX FOR THE REAL THING WE WANT TO RANDOMISE THE mask-target PAIRS
    % FIX? probably would have been better to start off with an array of
    % trial stucts, then randomise that.
    
    
    try
        % first we set up the display
        % Choosing the display with the highest dislay number is
        % a best guess about where you want the stimulus displayed.
        
        screens=Screen('Screens');
        screenNumber=max(screens);
        
        [window,rect]=Screen('OpenWindow', screenNumber,0,[],32,2);
        [centre_x,centre_y]= RectCenter(rect);
        params.centre_x = centre_x;
        params.centre_y = centre_y;
        % Retreive the maximum priority number
        topPriorityLevel = MaxPriority(window);
        
        % fprintf( '%d, %d\n',centre_x,centre_y);
        %  KbStrokeWait;
        
        Screen('FillRect', window, [0, 0, 0]);
        Screen('TextFont',window, params.targetFont);
        Screen('TextStyle', window, 0);
        Screen('TextSize',window, params.targetFontSize);
        
        % now the audio
        InitializePsychSound(1);
        pahandle = PsychPortAudio('Open', [], 2, 0, params.freq, 1, [], 0.01);
        chunkLength = 0.1; % length of audio chunks to grab for voice trigger
        PsychPortAudio('GetAudioData', pahandle, params.voiceKeyWindow + 1.0,chunkLength, chunkLength);
        % end of screen/audio initialisation
    catch
        
        fprintf('Error setting display up in GenerativeVisual\n');
        Screen('CloseAll');
        fclose('all');
        psychrethrow(psychlasterror);
    end
    
    try
        % Start of block. We're running an indefinite number of blocks with
        % nTrialsInBlock each.
        trial=1;
        
        % Start of experiment - loops over blocks
        while trial <= ntrials; % just makes sure we don't try to run more trials than there are stims.
    
            
            WaitSecs(1.0);
            
            % To cope with practice blocks at start of phases we need to know which trial no. to trigger things on
            % Would be better to code it in the stimulus file.
            
            % display ready text at start of block
            % maybe want a 'do something at start of block'
            
            if strcmp(stimData.group(trial), 'P')
                if strcmp(stimData.status(trial), 'word') && strcmp(stimData.speed(trial), 'slow')
                    displayTextAtNoFlip('In this part of the experiment you will see a word displayed at an angle.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y,window);
                    displayTextAtNoFlip('Two seconds later a second word will be presented horizontally on top of the first.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y + 50 ,window);
                    displayTextAtNoFlip('Your task is to read the second word out aloud as quickly as possible.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y + 100 ,window);
                    
                elseif strcmp(stimData.status(trial), 'word') && strcmp(stimData.speed(trial), 'fast')
                    displayTextAtNoFlip('In this part of the experiment you will see a word displayed at an angle.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y,window);
                    displayTextAtNoFlip('Half a second later a second word will be presented horizontally on top of the first.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y + 50 ,window);
                    displayTextAtNoFlip('Your task is to read the second word out aloud as quickly as possible.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y + 100 ,window);
                    
                elseif strcmp(stimData.status(trial), 'nonword') && strcmp(stimData.speed(trial), 'slow')
                    displayTextAtNoFlip('In this part of the experiment you will see a nonsense word displayed at an angle.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y,window);
                    displayTextAtNoFlip('Two seconds later a word will be presented horizontally on top of the nonsense word.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y + 50 ,window);
                    displayTextAtNoFlip('Your task is to read the word out aloud as quickly as possible.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y + 100 ,window);
                    
                elseif strcmp(stimData.status(trial), 'nonword') && strcmp(stimData.speed(trial), 'fast')
                    displayTextAtNoFlip('In this part of the experiment you will see a nonsense word displayed at an angle.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y,window);
                    displayTextAtNoFlip('Half a second later a word will be presented horizontally on top of the nonsense word.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y + 50 ,window);
                    displayTextAtNoFlip('Your task is to read the word out aloud as quickly as possible.',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y + 100 ,window);
                    
                else
                    fprintf('Unrecognised combination of conditions on trial %d: %s %s\n',trial, stimData.status(trial),stimData.speed(trial));
                    Screen('CloseAll');
                    fclose('all');
                end
                
                displayTextAt('Press any key to begin practice',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y + 150 ,window);
                
                KbStrokeWait;
                
                Screen('Flip',window);
                WaitSecs(3);
                doBlock(params.nPracticeTrials);
                WaitSecs(2)
                displayTextAt('End of practice',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y,window);
                WaitSecs(5.0);
                
            else
                displayTextAt(params.readyText,params.targetFont, params.messageFontSize, params.centre_x,params.centre_y,window);
                
                KbStrokeWait;  % COMMENT OUT FOR TESTING
                Screen('Flip',window);
                WaitSecs(1.0);
                
                doBlock(params.nTrialsInBlock);
            end % matches if strcmp(stimData.group(trial), 'P')
            
        end % matches: while trial <= ntrials  % end of blocks in expt loop
        
        
        % Done!
        % Close the audio device:
        PsychPortAudio('Close', pahandle);
        WaitSecs(2);
        displayTextAt('End of experiment',params.targetFont, params.messageFontSize, params.centre_x,params.centre_y,window);
        WaitSecs(3.0);
        Screen('CloseAll');
        fclose(params.dataFileID); % windows claims these files are still in use by matlab

        
    catch
        fprintf('Error in experiment control loop in GenerativeVisual\n');
        Screen('CloseAll');
        fclose('all');
        psychrethrow(psychlasterror);
    end % try..catch
    
    
    
    % write data to data file.
%     try
%         for trial = 1: ntrials;
%             fprintf(params.dataFileID, '%d, %s, %s, %s, %s, %s, %5.0f, %1.0f\n',trial, trialStruct(trial).group, trialStruct(trial).condition,trialStruct(trial).speed, trialStruct(trial).mask, trialStruct(trial).target, trialStruct(trial).RT, trialStruct(trial).error);
%             fprintf('%d, %s, %s, %s, %s, %s, %5.0f, %1.0f\n',trial, trialStruct(trial).group, trialStruct(trial).condition, trialStruct(trial).speed, trialStruct(trial).mask, trialStruct(trial).target, trialStruct(trial).RT, trialStruct(trial).error);
%         end;
%         fclose(params.dataFileID); % windows claims these files are still in use by matlab
%     catch
%         fprintf('Error writing data to %s\n', params.dataFilename);
%         fclose('all');
%         psychrethrow(psychlasterror);
%     end
     

 %   Screen('CloseAll');
    
catch
    % If an error occurs, the catch statements executed.  We restore as
    % best we can and then rethrow the error so user can see what it was.
    
    Screen('CloseAll');
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    
    fprintf('We''ve hit an error.\n');
    psychrethrow(psychlasterror);
    fprintf('This last text never prints.\n');
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                    doBlock
%
% NB this fn is nested within generativeVisual
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function doBlock(trialsInBlock)
        
        for trialInBlock=1:trialsInBlock;
            if trial > params.nTrialsTotal;
                break
            end
            
            % Use 'condition' to determine whether mask is word or nonword
            % should rename as status
            trialStruct(trial).condition = char(stimData.status(trial,1));
            
            if strcmp(trialStruct(trial).condition, 'word');
                trialStruct(trial).mask = char(stimData.words(trial,1));
            else
                trialStruct(trial).mask = char(stimData.nonwords(trial,1));
            end
            
            trialStruct(trial).speed = char(stimData.speed(trial,1));
            trialStruct(trial).group = char(stimData.group(trial,1));
            
            if strcmp(trialStruct(trial).speed,'fast');
                params.primeDuration = params.fastMask;
            else
                params.primeDuration = params.slowMask;
            end
            
            trialStruct(trial).target = char(stimData.targets(trial,1));
            try
                trialStruct(trial) =  doTrial(params, trialStruct(trial), trial, window, topPriorityLevel, pahandle);
            catch ME
                  fprintf('In doBlock. Something went wrong in doTrial on trial %d\n',trial);
                  ME   
            end
            
            trial = trial + 1;
        end  % End of trials in block loop
    end % end of doBlock function





end % end of generativeVisual




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                    doTrial
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% runs the fixation cross, mask, target, voice key sequence.
% We pass trialStruct in and out because MATLAB only effectively passes by
% reference until you write to the object, then it becomes a copy
% I really only need to return the RT and error so there's a lot of wasted
% copying of the rest of the struct here,
% but I'll leave it as it is.
% probably cleaner to nest it within generativeVisual as I did with doTrial
% then I wouldn't have needed any of the parameters.
% 'trial' is used to construct the audio data filename.
%
% I don't think the way I deal with overlaying the mask and the target is
% ideal. I should probably have been using the dontclear argument 
% Screen('Flip', windowPtr [, when] [, dontclear] [, dontsync] [,
% multiflip]);


function [trialStruct] = doTrial(params, trialStruct, trial, window, topPriorityLevel, pahandle)

[keyIsDown, secs, keyCode, deltaSecs] = KbCheck;% Wait for and check which key was pressed
 
 if (keyCode(KbName('ESCAPE')) == 1);
     fprintf('Got escape\n');
      psychrethrow('got escape');
 end;
 
     
 
% First display a fixation cross
displayTextAt(params.fixationText, params.targetFont, params.targetFontSize,params.centre_x,params.centre_y,window)
WaitSecs(params.fixationDuration);
Screen('Flip',window);
WaitSecs(0.5);


% we're doing the rotated masking text in an offscreen window
% first do the 'prime'
woff = Screen('OpenOffscreenwindow', window, [0,0,0]);
Screen('TextSize',woff, params.maskFontSize);
Screen('TextFont',woff, params.maskFont);
Screen('TextStyle', woff, 2);

maskTextbox = Screen('TextBounds', woff, trialStruct.mask);
[mask_xc, mask_yc] = RectCenter(maskTextbox);

Screen('DrawText', woff, trialStruct.mask, params.centre_x - mask_xc, params.centre_y - mask_yc, [255 255 255]);

% choose direction of rotation at random
% we'll dither the angle a bit as the two words obscure each
% other a lot at particular orientations
dither = randi([-5,5]);
if (randi([0,1]));
    angle = 15 + dither;
else
    angle = -15 + dither;
end;
Screen('DrawTexture',window,woff,[],[],angle); % this determines the angle of rotation

Priority(topPriorityLevel);
Screen('Flip',window);
% WaitSecs(randi(params.primeDuration * 10)/10); % FIX NEED TO USE KNOWN/CONTROLLED PRIME
WaitSecs(params.primeDuration);
Screen('Flip',window);
if(params.primeTargetISI > 0);
    WaitSecs(params.primeTargetISI);
end;

% now the mask-target combination

Screen('DrawTexture',window,woff,[],[],angle); % this determines the angle of rotation
% display the target - this is in normal orientation
StimulusOnsetTime = displayTextAt(trialStruct.target,params.targetFont, params.targetFontSize, params.centre_x, params.centre_y,window);

%WaitSecs(params.targetDuration); % this no longer does anything as we're waiting for the audio to be captured anyway.
Priority(0);
Screen('TextFont',window, 'Arial');
Screen('TextStyle', window, 0);

% start = GetSecs;

% fprintf('%d %d %d\n', StimulusOnsetTime, start, start -StimulusOnsetTime) 
% the difference between GetSecs at this point and StimulusOnsetTime is in the order of
% microsecs
start = StimulusOnsetTime;



[RT audioRT params.allaudiodata] = VoiceTriggerTerminate(pahandle,params.voiceKeyWindow,params.freq,params.allaudiodata,StimulusOnsetTime);

% t2 = GetSecs;
% fprintf('after trig %f %f\n', GetSecs, t2-t1);

% respText = getEchoString(w,'type response:', 40,800); % how do you use useKbCheck=1

% fprintf('********* RT:  %5.0f %s %s\n',RT, trialStruct.mask, trialStruct.target);
% fprintf('length of audiodata: %d\n',length(audiodata));
Screen('Flip',window);
Screen('Close', woff); % close the offscreen window, otherwise they all hang around. Don't need to bother with the onscreen.
%WaitSecs(params.voiceKeyWindow - (GetSecs-start)); 

% we'll extend the mouseClick window to include the remaining part of the
% voiceKeyWindow
mouseClick = checkIntervalForMouse(1.0 + (params.voiceKeyWindow - (GetSecs-start))); 

[audiodata offset overflow tCaptureStart]= PsychPortAudio('GetAudioData', pahandle);
PsychPortAudio('Stop', pahandle);
   % fprintf('kkkkkkkkkk %d  %d\n',length(audiodata), offset);
 params.allaudiodata(offset+ 1:offset+length(audiodata))= audiodata;

% log everything in the trialStruct
trialStruct.RT = RT;
trialStruct.audioRT = audioRT;

% write the audio data
% this filename is generated from the stims so doesn't need to be
% passed from calling fn
filename = sprintf('%s/%d_%s_%s.wav',params.audioDir, trial, trialStruct.mask, trialStruct.target);
% fprintf('writing audio to: %s\n',filename);
wavwrite(params.allaudiodata,params.freq,16, filename);

% if the E clicks the mouse in this interval this returns 1, and we can say
% that this trial is an error.


% mouseClick = checkIntervalForMouse(1.0);
fprintf('MOUSE %d\n',mouseClick);
trialStruct.error = mouseClick;

    try
        fprintf(params.dataFileID, '%d, %s, %s, %s, %s, %s, %5.0f, %1.0f, %5.0f\n',trial, trialStruct.group, trialStruct.condition,trialStruct.speed, trialStruct.mask, trialStruct.target, trialStruct.RT, trialStruct.error, trialStruct.audioRT);
        fprintf('%d, %s, %s, %s, %s, %s, %5.0f, %1.0f, %5.0f\n',trial, trialStruct.group, trialStruct.condition, trialStruct.speed, trialStruct.mask, trialStruct.target, trialStruct.RT, trialStruct.error, trialStruct.audioRT)
    catch
        fprintf('Error writing data to %s\n', params.dataFilename);
        fclose('all');
        psychrethrow(psychlasterror);
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                    displayTextAt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% display text, in font and font size at given coords in window
% text is centred at the coords
% This is the only place where timing is critical as this is what we use to
% display the target
function [StimulusOnsetTime] = displayTextAt(txt,font, size, xc,yc,window)

Screen('TextFont',window, font);
Screen('TextSize',window, size);
textbox = Screen('TextBounds', window, txt);
[txt_xc, txt_yc] = RectCenter(textbox);

Screen('DrawText', window,txt,xc - txt_xc, yc - txt_yc,[255 255 255]);
% fprintf('DT %f\n', GetSecs);
[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip',window);
% fprintf('DT %f %f %f %f %f\n', VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos);

end

% text is centred at the coords
function displayTextAtNoFlip(txt,font, size, xc,yc,window)

Screen('TextFont',window, font);
Screen('TextSize',window, size);
textbox = Screen('TextBounds', window, txt);
[txt_xc, txt_yc] = RectCenter(textbox);

Screen('DrawText', window,txt,xc - txt_xc, yc - txt_yc,[255 255 255]);
% fprintf('DT %f\n', GetSecs);
%[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip',window);
% fprintf('DT %f %f %f %f %f\n', VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                    checkIntervalForMouse
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [resp] = checkIntervalForMouse(interval)

resp = 0;
stop = GetSecs + interval;
while GetSecs < stop;
    [x y buttons]=GetMouse;
    if buttons(1) || buttons(2);
        resp = 1;
    end
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                    voiceTrigger
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% returns RT in a fixed interval given by windowDuration (in secs)
% and samples the audio at freq Hz.
% returns zero for timeout.
function [RT audiodata] = voiceTriggerFixedInterval(pahandle, windowDuration, freq)

startTime = GetSecs;

% The moving average downsampling I put into this doesn't seem to do much
% with a window of 10 and 11.25kHz.  Works much better with 100
averagingWindow = 100;
backgroundNoiseToSample = 0.1; % secs of background noise to sample to determine threshold
backGroundNoiseMultiplier = 10; % multiply background noise level by this to give the adapted threshold.
% 10 seems fine

% Preallocate an internal audio recording buffer, and set it up to return
% chunks of 0.1s
chunkLength = 0.1;
[audiodata offset overflow tCaptureStart]= PsychPortAudio('GetAudioData', pahandle, windowDuration + 1.0,chunkLength, chunkLength);

% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero, i.e. record until recording
% is manually stopped.



% Start by c<ollecting 100ms of background noise and using that to
% determine the triger threshold
% should probably do some integration/down sampling here
%WaitSecs(backgroundNoiseToSample); % get the fist 100ms worth of audio

% Fetch current audiodata:
[audiodata offset overflow tCaptureStart]= PsychPortAudio('GetAudioData', pahandle);

% Compute maximum signal amplitude in this chunk of data
% and set the adaptedTriggerLevel to some multiple of that.
if ~isempty(audiodata);
    % adaptedTriggerLevel = mean(abs(audiodata(1,:))) * 5; % using mean here and below to crudely filter the input
    adaptedTriggerLevel = 0;
    for i=1:length(audiodata) - 2 * averagingWindow;
        adaptedTriggerLevel = max(adaptedTriggerLevel, mean(abs(audiodata(i:(i+averagingWindow)))));
    end;
    adaptedTriggerLevel = adaptedTriggerLevel * backGroundNoiseMultiplier;
else
    adaptedTriggerLevel = 0.5;
    fprintf('Didnt get any audiodata in voiceTriggerFixedInterval - shouldnt happen\n');
end;


% What we could do is to collect a chunk of sound, set off collecting another then,
% in that interval, go through the previous interval. The problem with that is that
% the trigger has to be done in a rolling window, so the edges of the chuks neeed special
% handling 
% Probably need to do a running average - subtract the first item and add
% the next, then check.
% Can we do this fast enough?
% [audiodata absrecposition overflow cstarttime] =
% PsychPortAudio('GetAudioData', pahandle [, amountToAllocateSecs][, minimumAmountToReturnSecs][, maximumAmountToReturnSecs][, singleType=0]);
% keep calling this 

% Set things up to grab 100ms of sound
% Compute average,
% check for resp
% do until response or window duration:
%     grab next 100ms
%     go through running average, checking for resp







%t4b = GetSecs;
% Fetch current audiodata: This takes < 1ms
% We'll say that the time this is called is the time the audio collection
% finishes.
audioDoneTime = GetSecs;
[audiodata offset overflow tCaptureStart]= PsychPortAudio('GetAudioData', pahandle);

if isempty(audiodata);
    fprintf('\n********* Error in voiceTriggerFixedInterval: audiodata empty ******\n');
end

done = 0;
RT = 0;
chunkDurationInSamples = freq * chunkLength;
adaptedTriggerLevelSum = adaptedTriggerLevel * chunkLength;
[audiodata offset overflow tCaptureStart]= PsychPortAudio('GetAudioData', pahandle);
movingSum = sum(abs(audiodata(i:(i+ averagingWindow))));
firstSampleForAverage = offset; % the first sample used in computing the current running average

while ~done;
    [audiodata offset overflow tCaptureStart]= PsychPortAudio('GetAudioData', pahandle);

    for i=1:length(audiodata);
        movingSum = movingSum + audiodata(i+offset) - audiodata(i+offset - chunkLength );
        if movingSum > adaptedTriggerLevelSum;
            done = 1;
            RT = i + offset * 1000/freq;
            break;
        end;
    end;
end;

   
    



% We're now getting RT by working out the time from the end of the
% audiodata to where the response is, and then subtracting this from the
% time from entering this fn to reading the audiodata.
% This makes allowance for any processing done in determining the adapted
% trigger level.
% This adds about 5-10ms to the estimated RT, so hardly worth doing.


% for i=1:length(audiodata) - 2 * averagingWindow;
%     if done == 0 && mean(abs(audiodata(i:(i+ averagingWindow)))) >= adaptedTriggerLevel;
%         RT = (audioDoneTime - startTime) * 1000  - (length(audiodata) - i) * 1000/freq;
%         
%         % RT = i * 1000/freq + backgroundNoiseToSample * 1000; % corect for the fact that we're using the
%         % first part fo the response interval to determine background
%         % noise, so need to add that onto the RT
%         %fprintf ('+++ %5.0f %5.0f\n',RT, xRT);
%         done = 1;
%     end
% end
% 


% Stop sound capture:
PsychPortAudio('Stop', pahandle);
% Fetch all remaining audio data out of the buffer - Needs to be empty
% before next trial:
PsychPortAudio('GetAudioData', pahandle);

if RT == 0;
    fprintf('No response at all within %d seconds. Max sample value = %d, adaptedTriggerLevel = %d\n', windowDuration, max(audiodata),adaptedTriggerLevel);
else
    fprintf ('+++ %5.0f %5.0f\n',RT);   
end
 
end

% RT is the real RT since display onset, audioRT is the voice-key trigger point in the audio file
function [RT, audioRT,  allaudiodata] = VoiceTriggerTerminate(pahandle, windowDuration,freq, allaudiodata, tStart)

% This starts by recording 100ms of audio and uses that to set a voice key threshold.
% It's safe to assume that there will be no real response < 100ms.
% It then reads in successive 100ms chunks and goes through each to check whether there
% is a 50 sample segment whose mean excedes that threshold, and calls the onset of that the RT.
% We measure the RT based on the count of audio samples.
% This fn then returns immediately with the audiodata collected so far and 
% it's the job of the calling fn to record a bit extra so it gets the whole of the word/window
% 

% The issue below has now been fixed 24-7-15
% The limitation of this is that if that it the threshold is exceded accross a chunk boundary the timing will be out
% a bit. It really needs to do something to deal with rolling over between chunks.
% But, on the other hand, 50 samples at 11025 is only 5ms which means that
% less than 1 in 20 times there will be an additional error of 5ms. The
% worst case is when 50 samples that would trigger straddle a chunk boundary but
% neither portion is sufficient to trigger alone.
% I could and probably should fix this, but it's not going to make any
% difference to anything
% It would probably work just as well by reading in 5ms chunks and not
% bothering to run throuh trying to find the exact onset.


try

processingFirstChunk = 1; % we're doing the first chunk of audio                                                 
triggerLevel = 0.1; % the actual trigger level (set later)
thresholdMultiplier = 15; % multiply the average level in the first 100ms by this to get a threshold
averagingWindow = 50; % average audio in this window to check for trigger so as to integrate a bit
chunkLength =  0.1;
done = 0;
% tStart = GetSecs;
RT = -1;
audioRT = -1;
offset = 0;
lastOffset = 0; 
% fprintf ('done initialisation **************\n');
% Open the default audio device [], with mode 2 (== Only audio capture),
% and a required latencyclass of two 2 == low-latency mode, as well as
% a frequency of 44100 Hz and 2 sound channels for stereo capture. We also
% set the required latency to a pretty high 20 msecs. Why? Because we don't
% actually need low-latency here, we only need low-latency mode of
% operation so we get maximum timing precision -- Therefore we request
% low-latency mode, but loosen our requirement to 20 msecs.
%
% This returns a handle to the audio device:

% original: I can't find the docs to know what the args are
% pahandle = PsychPortAudio('Open', [], 2, 2, freq, 2, [], 0.02);

% the 4th arg has to be 0 to do anyting on my machine.




% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero, i.e. record until recording
% is manually stopped.

PsychPortAudio('Start', pahandle, 1, 0, 1);

%fprintf('\ntGetSecs %d, tStart %d, GetSecs - tStart %d\n', GetSecs, tStart, GetSecs-tStart); % this is only a few ms

extraTime = (GetSecs-tStart) * 1000; % 

level = 0;
timeout = 0;


%%%%%%% Start by collecting 100ms of background noise and using that to
%%%%%%% determine the triger threshold


adaptedTriggerLevel = triggerLevel;

WaitSecs(0.1); % get the fist 100ms worth of audio
% Fetch current audiodata:
[audiodata offset overflow tCaptureStart]= PsychPortAudio('GetAudioData', pahandle);
% tCaptureStart seems to be 0, so can't use that.
% fprintf('offset = %d, tCaptureStart = %d  tStart %d %d   %d %d\n', offset, tCaptureStart, tStart, GetSecs,tStart,  GetSecs - tStart);

% Compute mean signal amplitude in this chunk of data
% and set the adaptedTriggerLevel to some multiple of that.
if ~isempty(audiodata)
     adaptedTriggerLevel = mean(abs(audiodata(1,:))) * thresholdMultiplier; % using mean here and below to crudely filter the input
else
    adaptedTriggerLevel = triggerLevel;
    fprintf('Didnt get any audiodata in GetVoiceTrigger - shouldnt happen\n')
end;





% Repeat as long as below trigger-threshold:

%lastOffset = 0
while level < adaptedTriggerLevel && done == 0;
    if GetSecs - tStart > windowDuration;
        fprintf('timeout\n');
        timeout = 1;
        break;
    end;
 %   fprintf('\n*************** fetching audiodata\n');
    WaitSecs(0.1);
    % Fetch current audiodata:
    %fprintf('*******  GetSecs %5d\n', int64((GetSecs - tStim) * 11025))
    [audiodata offset overflow tCaptureStart]= PsychPortAudio('GetAudioData', pahandle);
  %  fprintf('kkkkkkkkkk %d %d  %d\n',length(audiodata), length(audiodata(1,:)),offset);

    if isempty(audiodata)
        fprintf('audiodata empty\n')
        RT = -77; % so I can spot this kind of error in the response file
        audioRT = -77;
        return
    end
    
  
    now = GetSecs;
    allaudiodata(offset+ 1:offset+length(audiodata))= audiodata; % concatenate this chunk onto allaudiodata
    % audiodata is preallocated in the calling fn.
    
   %  fprintf('xxx length %d  %d offset %d  lastOffset %d\n',length(audiodata), length(allaudiodata), offset, lastOffset);
    % Compute maximum signal amplitude in this chunk of data:
    if ~isempty(audiodata)
   %     fprintf('yyy length %d  %d offset %d  lastOffset %d\n',length(audiodata), length(allaudiodata), offset, lastOffset);    

    %   fprintf('******* GetSecs %5d error: %5d\n', int64((now - tStart) * 11025), int64(((now - tStart) * 11025) -offset - length(audiodata)));
       lastOffset = offset;
        
        
           % RT measured in audio samples rather than time as this is the best way to measure the time since onset of sampling     
            if processingFirstChunk == 0 
               startLooking = 0;
               processingFirstChunk = 1;
           else
               startLooking = offset - (2 * averagingWindow); % i.e. start looking from the last part of the averaging window in the previous chunk
               % (2 * averagingWindow) just makes sure it continues from where
               % it left off in the previous chunk - in fact a bit before 
            end;

           % for each chunk read in, this runs through a moving average of
           % averagingWindow samples to see if the threshold has been exceded.
           % It stops 2 * averagingWindow samples before the end of the
           % complete allaudiodata

           if length(audiodata) - 2 * averagingWindow + offset < 0;
               fprintf('Error in VoiceTriggerTerminate. length(audiodata) - 2 * averagingWindow + offset < 0. length %d, averagingWindow %d, offset %d\n',length(audiodata), averagingWindow, offset);
               fprintf('Calling this trial an error\n');
               RT = -1;
               done = 1;
           else

                for i=1 + startLooking:length(audiodata) - 2 * averagingWindow + offset;
                    if done == 0 && mean(abs(allaudiodata(i:(i+ averagingWindow)))) >= adaptedTriggerLevel; % THIS IS WHERE IT SOMETIMES CRASHES - 10-8-2015
                                                                                                            % We've hit an error.
                                                                                                            % ??? Subscript indices must either be real positive integers or logicals.
                                                                                                            % Error in ==> Generative_voicekey>VoiceTriggerTerminate at 925
                        audioRT = i * 1000/freq; 
                        RT = audioRT + extraTime;
                        % hardly worth adding extraTime as it's only about 1ms
                        done = 1;
                    end
                end

           end;
           

    else % matches:  ~isempty(audiodata)
        % when the error occurred audiodata was empty, but it neve made it
        % to here
        level = 0;
        fprintf('\n********* audiodata empty ******\n');
        fprintf('This should never happen\n');
        fprintf('Calling this trial an error\n');
        RT = -88; % so I can spot this kind of error in the response file
        audioRT = -88;
        done = 1;
    end;
    
    
end

catch ME   % This should catch any errors in this fn and allow the prog to continue
        fprintf('\nError in VoiceTriggerTerminate\n\n');
        ME
       % fprintf('\n\nlength of audiodata %d\n', length(audiodata));
        fprintf('\nThis should never happen\n');
        fprintf('Calling this trial an error - just carry on\n');
        RT = -99; % so I can spot this kind of error in the response file
        audioRT = -99;
        done = 1;
        return
    
end

end








