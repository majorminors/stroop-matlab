% resize pixels to a visual angle for a specified pix per unit and distance of another computer
% requires:
% display.screen_width              width of current screen in units
% display.resolution                number of pixels of current screen wide
% pix                               size in pixels to resize
% oldDist                           old distance from screen
% oldPPU                            old pixels per unit
function ang = resizer(display,pix,oldDist,oldPPU)

sz = (display.screen_width)/display.window_size(1)*pix/oldPPU; % resize the pixel resolution to the size of the object 'pix' to the old pix per unit
ang = 2*180*atan(sz/(2*oldDist))/pi; % get the visual angle for the old distance

return
end
