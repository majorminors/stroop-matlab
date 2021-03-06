% pix = angle2pix(display,ang)
%
% calculates pixel size from visual angles, assuming isotropic (square) pixels
%
% requires:
% display.screen_distance           distance from screen in cm
% display.screen_width              width of screen in cm
% display.resolution                number of pixels of in horizontal direction - this needs to be calculated after the window is opened for the dots
%% adapted from G.M. Boynton (University of Washington)
%% last edit D. Minors 18 November 2019
%% start function

function pix = angle2pix(display,ang)
pixSize = display.screen_width/display.resolution(1);   % cm/pix
sz = 2*display.screen_distance*tan(pi*ang/(2*180));  %cm
pix = round(sz/pixSize);   % pix 
return
end
