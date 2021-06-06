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

% get file list

theDir = dir(datadir);

fileNames = {theDir.name};

%% loop through files

cbu = {};

for i = 1:numel(fileNames)
    
    thisName = regexp(fileNames{i}, '_', 'split');
    
    if startsWith(thisName(1),'S') && ~any(contains(thisName,'Procedure')) && ~any(contains(thisName,'.wav'))
        
        task = cellstr(thisName{4}); % task
        stim = regexp(thisName{5},'.mat','split'); % stimulus
        stim = stim(1);
        
        tempFile = load([datadir,filesep,fileNames{i}]);
        
        cbuResults = tempFile.d.results;
        
        for block = 1:size(cbuResults,3)
            for trial = 1:size(cbuResults,1)
                
                cbu = [cbu; cbuResults(trial,1,block), cbuResults(trial,2,block), trial, block, cbuResults(trial,3,block)];
                
            end; clear trial
        end; clear block
        
    elseif startsWith(thisName(1),'onset')
        
        tempFile = load([datadir,filesep,fileNames{i}]);
        
        reading = tempFile.d.result;
        
    end
    
end


% put the datasets in comparable structures

for cbutrial = 1:size(cbu,1)
    
    checkarray(cbutrial,:) = [cbu(cbutrial,1:5),0,0];
    
    
    for searchidx = 1:size(reading,1)
        
        if strcmp(reading(searchidx,1),cbu(cbutrial,1)) &&...
                strcmp(reading(searchidx,2),cbu(cbutrial,2)) &&...
                (reading{searchidx,3} == cbu{cbutrial,3}) &&...
                (reading{searchidx,4} == cbu{cbutrial,4})
            checkarray(cbutrial,6) = reading(searchidx,5);
            checkarray(cbutrial,7) = num2cell(diff([cbu{cbutrial,5},reading{searchidx,5}]));
        end
        
    end; clear searchidx
    
end; clear cbutrial

