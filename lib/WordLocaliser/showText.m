function showText(p,textToShow)

% Screen('TextSize', p.window, 80);
% Screen('TextFont', p.window, 'Courier');
DrawFormattedText(p.window, textToShow, 'center', 'center', p.white);
Screen('Flip', p.window);

end