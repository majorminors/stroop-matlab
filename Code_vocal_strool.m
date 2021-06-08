close all;
clearvars;
clc;

fprintf('setting up %s\n', mfilename);
p = struct(); % keep some of our parameters tidy
d = struct(); % set up a structure for the data info
t = struct(); % set up a structure for temp data

% set up variables
rootdir = pwd; %% root directory - used to inform directory mappings and will save plots here
datadir = fullfile(rootdir,'data','behav_pilots'); % where are the files?
savefilename = 'processed_data';
save_file = fullfile(datadir,savefilename);


% directory mapping
addpath(genpath(fullfile(rootdir, 'lib'))); % add libraries path
addpath(genpath(fullfile(rootdir,datadir))); % add data path

% get file list
thisDir = dir(datadir);
subjectFolders = {thisDir.name};
clear thisDir;

for subjFolder = 1:numel(subjectFolders)
    
    if ~startsWith(subjectFolders(subjFolder), 'S') %|| startsWith(subjectFolders(subjFolder), 'S02')
        continue % skip . and .. results from dir
    end
    
    disp('working with subject')
    disp(subjectFolders(subjFolder))
    WaitSecs(1);
    
    % get file list
    thisDir = dir(fullfile(datadir,subjectFolders{subjFolder}));
    fileNames = {thisDir.name};
    clear thisDir;
    
    if exist(fullfile(datadir,subjectFolders{subjFolder},'onsets.mat'),'file')
        altResults = load(fullfile(datadir,subjectFolders{subjFolder},'onsets.mat'));
        altResults = altResults.d.result;
    else
        altResults = doOnsetDetection(datadir,subjectFolders,subjFolder);
    end
    
    d.subjects(subjFolder).results = analysis_coding(datadir,subjectFolders,subjFolder);
    
    d.subjects(subjFolder).results = getAltOnsets(d.subjects(subjFolder).results,altResults);
    
    % now some filtering
    
    sizes = strcmp(d.subjects(subjFolder).results(:,1),'size');%.*~strcmp(d.subjects(subjFolder).results(:,2),'training');
    colours = strcmp(d.subjects(subjFolder).results(:,1),'colour');%.*~strcmp(d.subjects(subjFolder).results(:,2),'training');
    congruents= strcmp(d.subjects(subjFolder).results(:,6),'congruent');%.*~strcmp(d.subjects(subjFolder).results(:,2),'training');
    incongruents = strcmp(d.subjects(subjFolder).results(:,6),'incongruent');%.*~strcmp(d.subjects(subjFolder).results(:,2),'training');
    fonts = strcmp(d.subjects(subjFolder).results(:,2),'font');
    falsefonts = strcmp(d.subjects(subjFolder).results(:,2),'falsefont');
    
    d.subjects(subjFolder).colour_congruent = cell2mat(d.subjects(subjFolder).results(find(colours.*congruents),5));
    d.subjects(subjFolder).colour_incongruent = cell2mat(d.subjects(subjFolder).results(find(colours.*incongruents),5));
    d.subjects(subjFolder).colour_congruent_fonts = cell2mat(d.subjects(subjFolder).results(find(colours.*congruents.*fonts),5));
    d.subjects(subjFolder).colour_incongruent_fonts = cell2mat(d.subjects(subjFolder).results(find(colours.*incongruents.*fonts),5));
    d.subjects(subjFolder).colour_incongruent_falsefonts = cell2mat(d.subjects(subjFolder).results(find(colours.*incongruents.*falsefonts),5));
    d.subjects(subjFolder).colour_congruent_falsefonts = cell2mat(d.subjects(subjFolder).results(find(colours.*congruents.*falsefonts),5));
    d.subjects(subjFolder).size_congruent = cell2mat(d.subjects(subjFolder).results(find(sizes.*congruents),5));
    d.subjects(subjFolder).size_incongruent = cell2mat(d.subjects(subjFolder).results(find(sizes.*incongruents),5));
    d.subjects(subjFolder).size_congruent_fonts = cell2mat(d.subjects(subjFolder).results(find(sizes.*congruents.*fonts),5));
    d.subjects(subjFolder).size_incongruent_fonts = cell2mat(d.subjects(subjFolder).results(find(sizes.*incongruents.*fonts),5));
    d.subjects(subjFolder).size_incongruent_falsefonts = cell2mat(d.subjects(subjFolder).results(find(sizes.*incongruents.*falsefonts),5));
    d.subjects(subjFolder).size_congruent_falsefonts = cell2mat(d.subjects(subjFolder).results(find(sizes.*congruents.*falsefonts),5));
    
    
    d.subjects(subjFolder).means = [...
        nanmean(d.subjects(subjFolder).colour_congruent),nanmean(d.subjects(subjFolder).colour_incongruent);...
        nanmean(d.subjects(subjFolder).colour_congruent_falsefonts),nanmean(d.subjects(subjFolder).colour_incongruent_falsefonts);...
        nanmean(d.subjects(subjFolder).colour_congruent_fonts),nanmean(d.subjects(subjFolder).colour_incongruent_fonts);...
        nanmean(d.subjects(subjFolder).size_congruent),nanmean(d.subjects(subjFolder).size_incongruent);...
        nanmean(d.subjects(subjFolder).size_congruent_falsefonts),nanmean(d.subjects(subjFolder).size_incongruent_falsefonts);...
        nanmean(d.subjects(subjFolder).size_congruent_fonts),nanmean(d.subjects(subjFolder).size_incongruent_fonts)];
    
    
end

removeThese=[];
for subj = 1:numel(d.subjects)
    if isempty(d.subjects(subj).results)
        removeThese=[removeThese,subj];
    end
end
d.subjects(removeThese)=[]; clear removeThese

jaspitup(datadir,'rts',d);
jaspitup(datadir,'incong-cong-rts',d);

disp('saving');

save(save_file);

disp('done!');

function d = doOnsetDetection(datadir,subjectFolders,subjFolder)
p.audiofilepattern = '*.wav'; % specify *.extension
p.produce_threshplot = 1; % produce and save plot of onsets (happens in function)
customYlim = 1; % custom ylim for comparing plots
p.produce_txtfile = 0; % produce and save textfile of [filenames, onsets] (happens in function)
p.produce_meanplot = 0; % produce and save a plot of mean with SEM bars (happens in this file)
p.produce_boxplot = 1; % produce and save a boxplot of onset times (happens in this file)
% audio processing settings
p.beginFreq = 125; % bandpath filter frequency from
p.endFreq = 11000; % bandpath filter frequency to
p.thresh4 = 0.2; % threshold
p.startvalue = 0; % skip range for first detection (ms)
p.stepw = 100; % stepwidth for calculating rolling SD (in samples)

%% get file information
t.fileinfo = dir(fullfile(datadir,subjectFolders{subjFolder},p.audiofilepattern)); % find all the datafiles and get their info
t.folderpath = fullfile(datadir,subjectFolders{subjFolder});
for file = 1:length(t.fileinfo)
    d.filenames(file) = {t.fileinfo(file).name}; % get the names of the files
end

% get date string for output files
t.actdat=datestr(datetime('now','TimeZone','local','Format','d-MMM-y_HH-mm-ss'));
t.actdat(t.actdat==' ')='_';
t.actdat(t.actdat==':')='-';
% get the folder path to id plots
t.out=regexp(t.folderpath,filesep,'split');

[d.onset,d.mean] = detect_voice_onset_loop(d.filenames, t.folderpath, p.beginFreq, p.endFreq, p.thresh4, p.startvalue, p.stepw,p.produce_threshplot,customYlim,p.produce_txtfile);
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

save([datadir,filesep,subjectFolders{subjFolder},filesep,'onsets'],'d')
end

function existingResults = getAltOnsets(existingResults,altResults)

for existingTrial = 1:size(existingResults,1)
    
    if existingResults{existingTrial,5} == -99 || existingResults{existingTrial,5} < 300
        
        for searchidx = 1:size(altResults,1) % loop through alt results for matching
            
            if strcmp(altResults(searchidx,1),existingResults(existingTrial,1)) &&... % task
                    strcmp(altResults(searchidx,2),existingResults(existingTrial,2)) &&... % stim
                    (altResults{searchidx,3} == existingResults{existingTrial,3}) &&... % trial
                    (altResults{searchidx,4} == existingResults{existingTrial,4}) % block
                
                existingResults{existingTrial,5} = altResults{searchidx,5}; % replace the onset
                
            end
            
        end; clear searchidx
        
    end
    
    if existingResults{existingTrial,5} < 300 % if it's still not valid
        existingResults{existingTrial,5} = NaN; % make it a NaN
    end
    
end; clear existingTrial

end

function jaspitup(datadir,type,d)

savefile = fullfile(datadir,[type '.txt']); %%file name
fid = fopen(savefile,'a');

switch type
    case {'ies','rts'}
        fprintf(fid, '%s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t \n',...
            'subjectid',...
            'colour congruent',...
            'colour incongruent',...
            'colour congruent falsefont',...
            'colour incongruent falsefont',...
            'colour congruent font',...
            'colour incongruent font',...
            'size congruent',...
            'size incongruent',...
            'size congruent falsefont',...
            'size incongruent falsefont',...
            'size congruent font',...
            'size incongruent font');
    case {'incong-cong-ies','incong-cong-rts'}
        fprintf(fid,'%s \t %s \t %s \t %s \t %s \t \n',...
            'subjectid',...
            'colour falsefont',...
            'colour font',...
            'size falsefont',...
            'size font');
end

for subj = 1:numel(d.subjects)
    fprintf(1, 'working with subject %1.0f\n', subj); % print that so you can check
    
    switch type
        case 'ies'
            % fprintf(fid, '%f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t \n',...
            %     subj,...
            %     d.subjects(subj).results.ies(1,1),...
            %     d.subjects(subj).results.ies(1,2),...
            %     d.subjects(subj).results.ies(2,1),...
            %     d.subjects(subj).results.ies(2,2),...
            %     d.subjects(subj).results.ies(3,1),...
            %     d.subjects(subj).results.ies(3,2),...
            %     d.subjects(subj).results.ies(4,1),...
            %     d.subjects(subj).results.ies(4,2),...
            %     d.subjects(subj).results.ies(5,1),...
            %     d.subjects(subj).results.ies(5,2),...
            %     d.subjects(subj).results.ies(6,1),...
            %     d.subjects(subj).results.ies(6,2));
        case 'rts'
            fprintf(fid, '%f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t \n',...
                subj,...
                d.subjects(subj).means(1,1),...
                d.subjects(subj).means(1,2),...
                d.subjects(subj).means(2,1),...
                d.subjects(subj).means(2,2),...
                d.subjects(subj).means(3,1),...
                d.subjects(subj).means(3,2),...
                d.subjects(subj).means(4,1),...
                d.subjects(subj).means(4,2),...
                d.subjects(subj).means(5,1),...
                d.subjects(subj).means(5,2),...
                d.subjects(subj).means(6,1),...
                d.subjects(subj).means(6,2));
        case 'incong-cong-ies'
            %         fprintf(fid, '%f \t %f \t %f \t %f \t %f \t \n',...
            %             subj,...
            %             d.subjects(subj).results.ies(2,2)-d.subjects(subj).results.ies(2,1),...
            %             d.subjects(subj).results.ies(3,2)-d.subjects(subj).results.ies(3,1),...
            %             d.subjects(subj).results.ies(5,2)-d.subjects(subj).results.ies(5,1),...
            %             d.subjects(subj).results.ies(6,2)-d.subjects(subj).results.ies(6,1));
        case 'incong-cong-rts'
            fprintf(fid, '%f \t %f \t %f \t %f \t %f \t \n',...
                subj,...
                d.subjects(subj).means(2,2)-d.subjects(subj).means(2,1),...
                d.subjects(subj).means(3,2)-d.subjects(subj).means(3,1),...
                d.subjects(subj).means(5,2)-d.subjects(subj).means(5,1),...
                d.subjects(subj).means(6,2)-d.subjects(subj).means(6,1));
    end
    
end


fclose('all');

end