% angle = pix2angle(display,pix)
%
% converts monitor pixels into degrees of visual angle, assuming isotropic (square) pixels
%
% requires:
% display.screen_distance           distance from screen in cm
% display.screen_width              width of screen in cm
% display.resolution                number of pixels of in horizontal direction - this needs to be calculated after the window is opened for the dots
%% adapted from G.M. Boynton (University of Washington)
%% last edit D. Minors 18 November 2019
%% start function

function ang = pix2angle(display,pix)
pixSize = display.screen_width/display.resolution(1);   %cm/pix
sz = pix*pixSize;  %cm
ang = 2*180*atan(sz/(2*display(1).screen_distance))/pi;
return
end
