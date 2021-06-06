%% deal with wav files
% Dorian Minors
% Created: JAN21
% 
% will run examination of .wav files for onset time
% 
% can choose to either loop through many files and return onset times, or examine
% features of a single file with p.visualcheck
% 
% produces:
%   - d.onset = vector of onset times for each file
%   - d.filenames = vector of cells with the name of each file (to match means to file)
%   - d.mean = mean onset
%   - d.sem = sem of onsets
%   - plot of mean onset time with SEM bars saved as bitmap
%   - boxplot of onset times saved as bitmap
%
%   subfunction detect_voice_onset_loop produces (on request):
%       - timestamped textfile, saved in rootdir, with list of filenames and onset times
%       - timestamped plot of onset times as bitmap file, saved in rootdir
%   subfunction detect_voice_onset_visual_check produces (on request):
%       - plot with detailed breakdown of individual .wav file saved in the rootdir as bitmap

%% set up

close all;
clearvars;
clc;

fprintf('setting up %s\n', mfilename);
p = struct(); % keep some of our parameters tidy
d = struct(); % set up a structure for the data info
t = struct(); % set up a structure for temp data

% set up variables
rootdir = pwd; %% root directory - used to inform directory mappings and will save plots here
%datadir = fullfile(rootdir,'results','standard','wait_for_mic_approval_false','delay_0ms','chrome','resultID_11'); % where are the files?
datadir = fullfile(rootdir,'data','behav_pilots','S01'); % where are the files?
p.visualcheck = 1; % 0 = loop through all files to get an overview, 1 = detailed plots on a single file (each option has settings, see below)

% if ~p.visualcheck (i.e. getting overview of all files)
p.datafilepattern = '*.wav'; % specify *.extension
p.produce_threshplot = 1; % produce and save plot of onsets (happens in function)
customYlim = 1; % custom ylim for comparing plots
p.produce_txtfile = 0; % produce and save textfile of [filenames, onsets] (happens in function)
p.produce_meanplot = 0; % produce and save a plot of mean with SEM bars (happens in this file)
p.produce_boxplot = 1; % produce and save a boxplot of onset times (happens in this file)

% if p.visualcheck (i.e. checking a single file in detail)
p.checkfilename = 'S01_vocal_Stroop_colour_falsefont_audio_27_4.wav';% specify filename with extension
p.save_plot = 0; % save the plot it produces

% audio processing settings
p.beginFreq = 125; % bandpath filter frequency from
p.endFreq = 11000; % bandpath filter frequency to
p.thresh4 = 0.2; % threshold
p.startvalue = 0; % skip range for first detection (ms)
p.stepw = 100; % stepwidth for calculating rolling SD (in samples)

% directory mapping
addpath(genpath(fullfile(rootdir, 'lib'))); % add libraries path
addpath(genpath(fullfile(rootdir,datadir))); % add data path

%% get file information
t.fileinfo = dir(fullfile(datadir, p.datafilepattern)); % find all the datafiles and get their info
t.folderpath = datadir;
for file = 1:length(t.fileinfo)
    d.filenames(file) = {t.fileinfo(file).name}; % get the names of the files
end

% get date string for output files
t.actdat=datestr(datetime('now','TimeZone','local','Format','d-MMM-y_HH-mm-ss'));
t.actdat(t.actdat==' ')='_';
t.actdat(t.actdat==':')='-';
% get the folder path to id plots
t.out=regexp(t.folderpath,filesep,'split');

%% loop through files, get names, and pass it to detect_voice_onset_loop
if ~p.visualcheck
    [d.onset,d.mean] = detect_voice_onset_loop(d.filenames, t.folderpath, p.beginFreq, p.endFreq, p.thresh4, p.startvalue, p.stepw,p.produce_threshplot,customYlim,p.produce_txtfile);
    d.sem = nansem(d.onset);
    if p.produce_meanplot
        meanplot = figure;
        plot(d.mean,'*')
        hold on
        errorbar(d.mean,d.sem);
        if exist('customYlim','var'); axis([0,2,0,customYlim]); end
        hold off
        t.savename = ['thresholds_meanplot_',t.out{length(t.out)-1},'_filter',num2str(p.beginFreq),'to',num2str(round(p.endFreq/1000)),'k_thresh',num2str(p.thresh4),'_',t.actdat,'.bmp'];
        saveas(meanplot,t.savename,'bmp')
    end
    if p.produce_boxplot
        bxplot = figure;
        hold on
        boxplot(d.onset);
        if exist('customYlim','var'); axis([0,2,0,customYlim]); end
        hold off
        t.savename = ['thresholds_boxplot_',t.out{length(t.out)-1},'_filter',num2str(p.beginFreq),'to',num2str(round(p.endFreq/1000)),'k_thresh',num2str(p.thresh4),'_',t.actdat,'.bmp'];
        saveas(bxplot,t.savename,'bmp')
    end

    for i = 1:length(d.filenames)
        
        name = regexp(d.filenames{i}, '_', 'split');
        d.result(i,1) = cellstr(name{4}); % task
        d.result(i,2) = cellstr(name{5}); % stimulus
        d.result(i,3) = num2cell(str2num(name{7})); % trial
        block = regexp(name{8},'.wav','split');
        d.result(i,4) = num2cell(str2num(block{1})); % block
        d.result(i,5) = num2cell(1000*d.onset(i)); % onset
        d.result(i,6) = d.filenames(i);
        
    end
    
    save([datadir,filesep,'onsets'],'d')
    
    
end

%% loop through files, get names, and pass it to detect_voice_onset_loop
if p.visualcheck
    detect_voice_onset_visual_check(d.filenames(find(strcmp(d.filenames,p.checkfilename))), t.folderpath, p.beginFreq, p.endFreq, p.thresh4, p.startvalue, p.stepw,p.save_plot)
end
