function do_instructions(p,instructions)

if p.manual_stroop
    switch instructions
        case 'first'
            instruction_text = 'In this experiment\nyou will see images on the screen\nand respond by pressing buttons.\nThere are four different tasks in this experiment.\nEach one is slightly different, although all are similar.\nAt the start of each task, you will get some instructions.\nThen there will be a short training period\nduring which we will tell you the correct answer after each trial.\nThen you will start the block properly and you will not get any feedback until the next block.\nWhen ready, press anything to continue.';
        case 'height'
            instruction_text = 'In this version of the task,\nyou must report the HEIGHT of the image\nby pressing a button.\nFrom left to right, the buttons indicate:\n\nSHORT, MEDIUM, or TALL\n\nPlease keep your eyes on the centre of the screen throughout.\n\nPress anything to continue.';
        case 'colour'
            instruction_text = 'In this version of the task,\nyou must report the COLOUR of the image\nby pressing a button.\nFrom left to right, the buttons indicate:\n\nRED, BLUE, or GREEN\n\nPlease keep your eyes on the centre of the screen throughout.\n\nPress anything to continue.';
        case 'training'
            instruction_text = 'This is a practice on an easy stimulus.\nYou will get feedback each trial.\nPress anything to continue.';
        case 'practice'
            instruction_text = 'This is a practice with a complex stimulus.\nYou will get feedback each trial.\nPress anything to continue.';
        case 'test'
            instruction_text = 'Now we begin the test.\nYou will now only get a feedback score\nafter a certain number of trials.\nPress anything to continue.';
    end
elseif p.vocal_stroop
    switch instructions
        case 'first'
            instruction_text = 'In this experiment\nyou will see images on the screen\nand respond by speaking aloud.\nThere are four different tasks in this experiment.\nEach one is slightly different, although all are similar.\nAt the start of each task, you will get some instructions.\nThen there will be a short training period\nduring which we will tell you the correct answer after each trial.\nThen you will start the block properly and you will not get any feedback until the next block.\nWhen ready, press anything to continue.';
        case 'height'
            instruction_text = 'In this version of the task,\nyou must report the HEIGHT of the image\nby speaking aloud.\nThe stimuli will either be:\n\nSHORT, MEDIUM, or TALL\n\nPlease keep your eyes on the centre of the screen throughout\nand answer as fast as possible.\n\nPress anything to continue.';
        case 'colour'
            instruction_text = 'In this version of the task,\nyou must report the COLOUR of the image\nby speaking aloud.\nThe stimuli will either be:\n\nRED, BLUE, or GREEN\n\nPlease keep your eyes on the centre of the screen throughout\nand answer as fast as possible.\n\nPress anything to continue.';
        case 'training'
            instruction_text = 'This is a practice on an easy stimulus.\nYou will get feedback each trial.\nPress anything to continue.';
        case 'practice'
            instruction_text = 'This is a practice with a complex stimulus.\nYou will get feedback each trial.\nPress anything to continue.';
        case 'test'
            instruction_text = 'Now we begin the test.\nYou will no longer get any feedback.\nPlease keep your eyes on the centre of the screen throughout\nand answer as fast as possible.\nPress anything to continue.';
    end
end
    
    DrawFormattedText(p.win, instruction_text, 'center', 'center', p.text_colour);
    Screen('Flip', p.win);
    WaitSecs(1); % so you hopefully don't have keys down!
    if p.buttonbox
        scansync([2:5],Inf); % wait for specified scansync triggers to return
    else
        KbWait();
    end

end
