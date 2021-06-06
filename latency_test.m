% Script for playing and recording with PsychPortAudio

close all;
clearvars;
clc;

p = struct(); % est structure for parameter values
d = struct(); % est structure for trial data
t = struct(); % another structure for untidy temp floating variables

rootdir = pwd; % root directory - used to inform directory mappings

%% Parameters

pahandle = [];
verbose = 0;   % set to 0 to limit the verbosity from PsychPortAudio
fs = 48000;    % samp freq in Hz
reqLatency = 0; % latency desired (not sure of the unit, but I always use 0)
bufferSize = 256; % in samples
secondsToAllocate = 2; % recording buffer
delayTime = 0.5; % amount of delay before playing sound

channelsPlay = [1 2]; % that should be left-right with the built-in sound card
channelsRec = 1; % that should also be the mic on a built-in sound card
deviceID = -1; % -1 is default

% duration_s = 2;
%signalToPlay = 0.01*rand(duration_s*fs, 2);
signalToPlay(:,1) = audioread([ PsychtoolboxRoot 'PsychDemos' filesep 'SoundFiles' filesep 'phaser.wav']); % first channel
signalToPlay(:,2) = audioread([ PsychtoolboxRoot 'PsychDemos' filesep 'SoundFiles' filesep 'phaser.wav']); % second channel

% now let's fill the rest of the time with the delay
delay = delayTime*fs;
totalDuration = secondsToAllocate*fs;
remainingTime = totalDuration-(delay+size(signalToPlay,1));
signalToPlay(:,1) = [zeros(delay,1);signalToPlay(:,1);zeros(remainingTime,1)];
signalToPlay(:,2) = [zeros(delay,1);signalToPlay(:,2);zeros(remainingTime,1)];

%% Initialize psychtoolbox
    
%check if Psych handle already exists
if ~isempty(pahandle)
    % close the audio device
    PsychPortAudio('Close');
end

%%%%%%%%% Play init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    AssertOpenGL;
catch ME
    if strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
        msg = ['It seems that PsychToolbox cannot be found. '...
            'Please double check that it is installed and in your path.'];
        causeException = MException('HeaAudioPsych:PsychToolboxNotAvailable', msg);
        ME = addCause(ME, causeException);
    end
    rethrow(ME)
end
    
% Perform basic initialization of the sound driver:
InitializePsychSound;
PsychPortAudio('Verbosity', verbose);

% For PsychToolbox, channels start at 0
channelsPlay = channelsPlay-1;
channelsRec = channelsRec-1;
    
%Channel selection (First row: play, second row: rec)
%
%For example: [1 2; 3 NaN]
channelSelection = NaN(2,max(length(channelsPlay),length(channelsRec)));
channelSelection(1,1:length(channelsPlay)) = channelsPlay;
channelSelection(2,1:length(channelsRec)) = channelsRec;

% Open the specified audio device <param.playDeviceID>, with default mode <2> (==Only rec),
% and a required latencyclass of zero (0 == no low-latency mode), as well as
% a sampling frequency of <fs> and a certain number of <channels> .
%Then comes the buffer size <param.bufferSize>, a suggested latency and
%the ID of the channels
%
% This returns a handle to the audio device:
pahandle = PsychPortAudio('Open', deviceID, 3, reqLatency, fs,...
    [length(channelsPlay), length(channelsRec)],...
    bufferSize,[],channelSelection);


% If the signal is mono, but there are more than one channel, duplicate the input
if isvector(signalToPlay) && length(channelsPlay) > 1
    signalToPlay = repmat(signalToPlay, 1, length(channelsPlay));
end

% Check that the number of channels is in accordance with the signal size
if size(signalToPlay,2) ~= length(channelsPlay)
    error('signal must be a vector with the number of columns matching the number of channels')
end

% In PsychAudio, the signal needs to be in rows
signalToPlay = signalToPlay';

% Fill the audio playback buffer with the audio data
PsychPortAudio('FillBuffer', pahandle, signalToPlay);

% Initialize the buffer and temporary data
PsychPortAudio('GetAudioData', pahandle, secondsToAllocate);
recNbSamples = size(signalToPlay,2);
signalRecorded = zeros(recNbSamples,length(channelsRec));
nRec = 0;

% Start recording
PsychPortAudio('Start', pahandle);

%Wait the playback to be finished
while nRec < recNbSamples
    
    %Get data
    [audiodata, nRec] = PsychPortAudio('GetAudioData', pahandle);
    
    %audiodata will be empty if you look before the buffer of the sound
    %card is full again
    if ~isempty(audiodata)
        signalRecorded(nRec+1:nRec+size(audiodata,2),:) = audiodata';
    end
end

% Stop recording and drain buffer
PsychPortAudio('Stop', pahandle);
[~] = PsychPortAudio('GetAudioData', pahandle);

% If recNbSamples is not a multiple of the buffer size, there will be more
% samples recorded than asked bu the user
signalRecorded = signalRecorded(1:recNbSamples,:);


%% plot recorded signal


figure
hold on
plot(signalToPlay(1, :))
plot(signalRecorded)