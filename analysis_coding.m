function results = analysis_coding(datadir,subjectFolders,subjFolder)

%% deal with stroopjs data
% Dorian Minors
% Created: SEP20
%
%
%% set up



fprintf('setting up %s\n', mfilename);
p = struct(); % keep some of our parameters tidy
d = struct(); % set up a structure for the data info
t = struct(); % set up a structure for temp data

% set up variables

p.savefilename = 'processed_data';
save_file = fullfile(datadir,subjectFolders{subjFolder},p.savefilename);
% make sure this legend is correct per the experiment - we code accuracy on the
% legend, not the experiment

%% get file information
theDir = dir(fullfile(datadir,subjectFolders{subjFolder}));
fileNames = {theDir.name};
d.results = {}; % init this
for i = 1:numel(fileNames)
    
    thisName = regexp(fileNames{i}, '_', 'split');
    
    if startsWith(thisName(1),'S') && ~any(contains(thisName,'Procedure')) && ~any(contains(thisName,'training')) && ~any(contains(thisName,'.wav'))
        
        task = cellstr(thisName{4}); % task
        stim = regexp(thisName{5},'.mat','split'); % stimulus
        stim = stim(1);
        
        tempFile = load([datadir,filesep,subjectFolders{subjFolder},filesep,fileNames{i}]);
        
        tmpResults = tempFile.d.results;
        tmpStimMat = tempFile.d.stimulus_matrix;
        
        for block = 1:size(tmpResults,3)
            for trial = 1:size(tmpResults,1)
                
                stimIdx = tmpResults{trial,5,block};
                
                d.results = [d.results;...
                    tmpResults(trial,1,block),... % task
                    tmpResults(trial,2,block),... % stimulus
                    trial,...
                    block,...
                    tmpResults(trial,3,block),... % rt
                    tmpStimMat(stimIdx,4),... % congruency
                    tmpStimMat(stimIdx,5),... % word
                    tmpStimMat(stimIdx,6),... % ink
                    tmpResults(trial,6,block)]; % size
                
            
            end; clear trial
        end; clear block
    end
end


save(save_file);

results = d.results; % because matlab can't pass bits of structures?

disp('done coding subject');


%
% % init some results - same structure exists for each subject in d.subjects.results
% d.results.size = [];
% d.results.size_congruent = [];
% d.results.size_congruent_falsefont = [];
% d.results.size_congruent_font = [];
% d.results.size_incongruent = [];
% d.results.size_incongruent_falsefont = [];
% d.results.size_incongruent_font = [];
%
% d.results.colour = [];
% d.results.colour_congruent = [];
% d.results.colour_congruent_falsefont = [];
% d.results.colour_congruent_font = [];
% d.results.colour_incongruent = [];
% d.results.colour_incongruent_falsefont = [];
% d.results.colour_incongruent_font = [];
%
%
%
% fprintf('saving output from %s\n', mfilename);
% save(save_file,'d'); % save all data to a .mat file


    function accuracy = accthis(data)
        accuracy = sum(data)/length(data);
    end

return
end
