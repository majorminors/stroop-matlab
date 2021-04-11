% fixation size and thickness in pixels (40 and 4 are good), colour
% in normal PTB syntax, time in seconds.
function doFixation(PTBwindow,PTBrect,fixationTime,fixationColour,fixationSize,fixationThickness)
    
[xCenter, yCenter] = RectCenter(PTBrect); % get the center of the rect

% get coordinates for centering stimuli from fixation parameters
xCoords = [-fixationSize fixationSize 0 0];
yCoords = [0 0 -fixationSize fixationSize];
allCoords = [xCoords; yCoords];

% draw fixation
Screen('DrawLines', PTBwindow, allCoords, fixationThickness, fixationColour, [xCenter yCenter], 2);
Screen('Flip', PTBwindow);
WaitSecs(fixationTime);

end