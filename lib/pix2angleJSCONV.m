% angle = pix2angleJSCONV(display,pix)
%
% converts monitor pixels into degrees of visual angle, assuming isotropic (square) pixels
% filters this through a scaling to make the pixels = to 150dpi (as per a
% jsPsych experiment I was trying to match
%
% requires:
% display.screen_distance           distance from screen in cm
% display.screen_width              width of screen in cm
% display.resolution                this needs to be calculated after the window is opened
%% adapted from G.M. Boynton (University of Washington)
%% last edit D. Minors Apr 2021
%% start function

function ang = pix2angleJSCONV(display,pix)

%     set(0,'units','pixels'); 
pixwidth = display.resolution(1); % get screen size in pixels
%     set(0,'units','inches'); 
units = display.screen_width; % get screensize
%     % get the pixels per inch(unit)
ppi = pixwidth/units;
scaleFactor = ppi/150; % find out what the scale factor is to get it to 150ppi (same as stroop js)
pix = pix*scaleFactor;
pixSize = (display.screen_width/2.54)/display.resolution(1);   %inches/pix
sz = pix*pixSize;  %in
ang = 2*180*atan(sz/(2*(display(1).screen_distance/2.54)))/pi;
return
end
