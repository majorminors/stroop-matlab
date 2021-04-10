function do_instructions(p,instructions)
    

    switch instructions
        case 'first'
            instruction_text = 'In this experiment you will see images on the screen and respond by pressing buttons.\nThere are four different tasks in this experiment.\nEach one is slightly different, although all are similar.\nAt the start of each task, you will get some instructions.\nThen there will be a short training period during which we will tell you the correct answer after each trial.\nThen you will start the block properly and you will not get any feedback until the next block.\nWhen ready, press anything to continue.';
        case 'height'
            instruction_text = 'In this version of the task, you must report the HEIGHT of the image by pressing a button.\nFrom left to right, the buttons indicate SHORT, MEDIUM, or TALL\nPlease keep your eyes on the centre of the screen throughout.\nPress anything to continue.';
        case 'colour'
            instruction_text = 'In this version of the task, you must report the COLOUR of the image by pressing a button.\nFrom left to right, the buttons indicate RED, BLUE, or GREEN\nPlease keep your eyes on the centre of the screen throughout.\nPress anything to continue.';
        case 'training'
            instruction_text = 'This is a practice on an easy stimulus.\nYou will get feedback each trial.\nPress anything to continue.';
        case 'practice'
            instruction_text = 'This is a practice with a more difficult stimulus.\nYou will get feedback each trial.\nPress anything to continue.';
        case 'test'
            instruction_text = 'Now we begin the test. You will only get a feedback score after a certain number of trials now.\nPress anything to continue.';
    end

    
    DrawFormattedText(p.win, instruction_text, 'center', 'center', p.text_colour)
    Screen('Flip', p.win);
    KbWait()

end