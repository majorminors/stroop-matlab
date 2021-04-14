function showImage(p,imageLocation)

[theImage,~,theImgAlpha] = imread(imageLocation);
% now we have to do some extraneous shit to get the alpha channel to work
% it's already filled the red channel with the image matrix
theImage(:,:,2) = theImage(:,:,1); % add in the green channel
theImage(:,:,3) = theImage(:,:,1); % add in the blue channel
theImage(:,:,4) = theImgAlpha; % add in the alpha channel

% Get the size of the image
[s1, s2, s3] = size(theImage);

% Here we check if the image is too big to fit on the screen and abort if
% it is. See ImageRescaleDemo to see how to rescale an image.
if s1 > p.screenYpixels || s2 > p.screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end

% Make the image into a texture
imageTexture = Screen('MakeTexture', p.window, theImage);

% Draw the image to the screen, unless otherwise specified PTB will draw
% the texture full size in the center of the screen. We first draw the
% image in its correct orientation.
Screen('DrawTexture', p.window, imageTexture, [], [], 0);

% Flip to the screen
Screen('Flip', p.window);

end