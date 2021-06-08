%% do plotting
% Dorian Minors
% Created: SEP20
%
%
%% set up

close all;
clearvars;
clc;

fprintf('setting up %s\n', mfilename);
p = struct(); % keep some of our parameters tidy
d = struct(); % set up a structure for the data info
t = struct(); % set up a structure for temp data

% set up variables
rootdir = pwd;
datadir = fullfile(rootdir,'data/behav_pilots');
p.savefilename = 'processed_data';

plotdir = fullfile(datadir,'plots');
if ~exist(plotdir,'dir')
    mkdir(plotdir);
end
addpath(genpath(fullfile(rootdir, 'lib'))); % add libraries to path

load(fullfile(datadir,p.savefilename),'d');

% reorder everything for the functions, since I'm reusing them instead of
% writing them again
data=[];
for subj = 1:length(d.subjects)
    for trial = 1:size(d.subjects(subj).results,1)
        thisData(1,trial) = d.subjects(subj).results{trial,5};
        thisData(2,trial) = NaN;
        if strcmp(d.subjects(subj).results{trial,9},'short')
            thisData(3,trial) = 1;
        elseif strcmp(d.subjects(subj).results{trial,9},'medium')
            thisData(3,trial) = 2;
        elseif strcmp(d.subjects(subj).results{trial,9},'tall')
            thisData(3,trial) = 3;
        end
        if strcmp(d.subjects(subj).results{trial,7},'red')
            thisData(4,trial) = 1;
        elseif strcmp(d.subjects(subj).results{trial,7},'blue')
            thisData(4,trial) = 2;
        elseif strcmp(d.subjects(subj).results{trial,7},'green')
            thisData(4,trial) = 3;
        end
        if strcmp(d.subjects(subj).results{trial,6},'congruent')
            thisData(5,trial) = 1;
        elseif strcmp(d.subjects(subj).results{trial,6},'incongruent')
            thisData(5,trial) = 2;
        end
        if strcmp(d.subjects(subj).results{trial,1},'size')
            thisData(6,trial) = 1;
        elseif strcmp(d.subjects(subj).results{trial,1},'colour')
            thisData(6,trial) = 2;
        end
        if strcmp(d.subjects(subj).results{trial,2},'falsefont')
            thisData(7,trial) = 1;
        elseif strcmp(d.subjects(subj).results{trial,2},'font')
            thisData(7,trial) = 2;
        end
    end
    data=[data,thisData];
end




% Rows:
% 1) rt
% 2) response button
% 3) accuracy (0,1)
% 4) size (1 = short, 2 = md, 3 = tall)
% 5) colour (1 = red, 2 = blue,3 = green)
% 6) congruency (1 = congruent, 2 = incongruent)
% 7) test type (1 = size trial, 2 = colour trial)
% 8) font type (1 = falsefont, 2 = font)
%filter_data(data,sizing,colour,congruency,trialtype,font)
%plot([1 1]*1.5, ylim, '--k')                % vertical line at �x=1.5�
%plot(xlim, [1 1]*1.5, '--k')                % horizontal line at �y=1.5�



% an extended version
clear vars labs cols;
vars(1,:,1) = filter_data(data,[],[],'congruent','colour','font');
labs(1) = {'cong font'};
vars(2,:,1) = filter_data(data,[],[],'incongruent','colour','font');
labs(2) = {'incong font'};
vars(1,:,2) = filter_data(data,[],[],'congruent','sizes','font');
vars(2,:,2) = filter_data(data,[],[],'incongruent','sizes','font');
vars(3,:,1) = filter_data(data,[],[],'congruent','colour','falsefont');
labs(3) = {'cong falsefont'};
vars(4,:,1) = filter_data(data,[],[],'incongruent','colour','falsefont');
labs(4) = {'incong falsefont'};
vars(3,:,2) = filter_data(data,[],[],'congruent','sizes','falsefont');
vars(4,:,2) = filter_data(data,[],[],'incongruent','sizes','falsefont');
make_params_extended(vars,'means',labs,[540,770]); % almost, but there appears to be an effect of incongruency in the colour baseline!


clear vars labs cols;
vars(1,:,1) = filter_data(data,[],[],'incongruent','colour','font')-filter_data(data,[],[],'congruent','colour','font');
labs(1) = {'font'};
vars(2,:,1) = filter_data(data,[],[],'incongruent','colour','falsefont')-filter_data(data,[],[],'congruent','colour','falsefont');
labs(2) = {'falsefont'};
vars(1,:,2) = filter_data(data,[],[],'incongruent','sizes','font')-filter_data(data,[],[],'congruent','sizes','falsefont');
vars(2,:,2) = filter_data(data,[],[],'incongruent','sizes','falsefont')-filter_data(data,[],[],'congruent','sizes','falsefont');
make_params_extended(vars,'means',labs, [-20,120]);


clear vars labs cols;
labs = {'short','medium','tall'};
cols = {'r','b','g'};
vars(1,:,1) = filter_data(data,'short','red','congruent','sizes','font');
vars(2,:,1) = filter_data(data,'medium','red','congruent','sizes','font');
vars(3,:,1) = filter_data(data,'tall','red','congruent','sizes','font');
vars(1,:,2) = filter_data(data,'short','blue','congruent','sizes','font');
vars(2,:,2) = filter_data(data,'medium','blue','congruent','sizes','font');
vars(3,:,2) = filter_data(data,'tall','blue','congruent','sizes','font');
vars(1,:,3) = filter_data(data,'short','green','congruent','sizes','font');
vars(2,:,3) = filter_data(data,'medium','green','congruent','sizes','font');
vars(3,:,3) = filter_data(data,'tall','green','congruent','sizes','font');
make_params_extended(vars,'accuracy',labs,[60 100],cols); % almost, but there appears to be an effect of incongruency in the colour baseline!


clear vars labs cols;
labs = {'short','medium','tall'};
cols = {'r','b','g'};
vars(1,:,1) = filter_data(data,'short','red','incongruent','sizes','font');
vars(2,:,1) = filter_data(data,'medium','red','incongruent','sizes','font');
vars(3,:,1) = filter_data(data,'tall','red','incongruent','sizes','font');
vars(1,:,2) = filter_data(data,'short','blue','incongruent','sizes','font');
vars(2,:,2) = filter_data(data,'medium','blue','incongruent','sizes','font');
vars(3,:,2) = filter_data(data,'tall','blue','incongruent','sizes','font');
vars(1,:,3) = filter_data(data,'short','green','incongruent','sizes','font');
vars(2,:,3) = filter_data(data,'medium','green','incongruent','sizes','font');
vars(3,:,3) = filter_data(data,'tall','green','incongruent','sizes','font');
make_params_extended(vars,'accuracy',labs,[60 100],cols);
% is our stroop working:
% are incongruent trials slower than congruent trials in the stroop (colour-font) task?
clear vars;
vars(1,:) = filter_data(data,[],[],'congruent','colour','font');
vars(2,:) = filter_data(data,[],[],'incongruent','colour','font');
make_params(vars,'means'); % yes they are
saveas(gcf,'stroop','bmp'); 





% is our colour baseline working:
% are colour baseline (falsefont-colour) trials similar across both congruent and incongruent trials
% and somewhere between stroop (colour-font) congruent and incongruent trials?
clear vars;
vars(1,:) = filter_data(data,[],[],'congruent','colour','font');
vars(2,:) = filter_data(data,[],[],'congruent','colour','falsefont');
vars(3,:) = filter_data(data,[],[],'incongruent','colour','falsefont');
vars(4,:) = filter_data(data,[],[],'incongruent','colour','font');
make_params(vars,'means'); % kind of? seems like there might be an effect of incongruency though...
saveas(gcf,'colour-baseline','bmp')

% is there an effect of size (visualisation - though we should quantify)

% does the size task work as a word baseline?
% if so there should be no effect of congruency
clear vars;
vars(1,:) = filter_data(data,[],[],'congruent','sizes','falsefont');
vars(2,:) = filter_data(data,[],[],'incongruent','sizes','falsefont');
vars(3,:) = filter_data(data,[],[],'congruent','sizes','font');
vars(4,:) = filter_data(data,[],[],'incongruent','sizes','font');
make_params(vars,'means',1); % looks good, though fonts appear to interfere
plot([1 1]*2.5, ylim, '--k'); hold off
saveas(gcf,'word-baseline','bmp')

% performance should be worse for colour naming during incongruent trials
% than size naming
clear vars;
vars(1,:) = filter_data(data,[],[],'congruent','colour','font');
vars(2,:) = filter_data(data,[],[],'incongruent','colour','font');
vars(3,:) = filter_data(data,[],[],'congruent','sizes','font');
vars(4,:) = filter_data(data,[],[],'incongruent','sizes','font');
% make_params(vars,'means'); % yep!
% % but this shouldn't be true during false font trials
% clear vars;
vars(5,:) = filter_data(data,[],[],'congruent','colour','falsefont');
vars(6,:) = filter_data(data,[],[],'incongruent','colour','falsefont');
vars(7,:) = filter_data(data,[],[],'congruent','sizes','falsefont');
vars(8,:) = filter_data(data,[],[],'incongruent','sizes','falsefont');
make_params(vars,'means',1); % almost, but there appears to be an effect of incongruency in the colour baseline!
plot([1 1]*2.5, ylim, ':k');
plot([1 1]*6.5, ylim, ':k');
plot([1 1]*4.5, ylim, '--k'); hold off
saveas(gcf,'colour-vs-size','bmp')
% more concise version
clear vars;
vars(1,:) = filter_data(data,[],[],'incongruent','colour','font');
vars(2,:) = filter_data(data,[],[],'incongruent','sizes','font');
vars(3,:) = filter_data(data,[],[],'incongruent','colour','falsefont');
vars(4,:) = filter_data(data,[],[],'incongruent','sizes','falsefont');
make_params(vars,'means',1);
plot([1 1]*2.5, ylim, ':k');
saveas(gcf,'2x2','bmp')




% lets look at this congruency effect in the false font
% clear vars;
% vars(1,:) = filter_data(data,[],[],'congruent','colour','falsefont');
% vars(2,:) = filter_data(data,[],[],'incongruent','colour','falsefont');
% make_params(vars,'means');
clear vars;
vars(1,:) = filter_data(data,[],'red','congruent','colour','falsefont');
vars(2,:) = filter_data(data,[],'blue','congruent','colour','falsefont');
vars(3,:) = filter_data(data,[],'green','congruent','colour','falsefont');
vars(4,:) = filter_data(data,[],'red','incongruent','colour','falsefont');
vars(5,:) = filter_data(data,[],'blue','incongruent','colour','falsefont');
vars(6,:) = filter_data(data,[],'green','incongruent','colour','falsefont');
make_params(vars,'means',1); % could be incongruent blue, but mostly driven by incongruent green!
%plot(xlim, [1 1]*715, ':k');
plot([1 1]*3.5, ylim, '--k'); hold off
saveas(gcf,'falsefont-congruency','bmp')

% lets look at this difference in font/falsefont across size conditions
% clear vars;
% vars(1,:) = filter_data(data,[],[],'congruent','sizes','falsefont');
% vars(2,:) = filter_data(data,[],[],'incongruent','sizes','falsefont');
% vars(3,:) = filter_data(data,[],[],'congruent','sizes','font');
% vars(4,:) = filter_data(data,[],[],'incongruent','sizes','font');
% make_params(vars,'means',1);
% plot([1 1]*2.5, ylim, '--k'); hold off
clear vars;
vars(1,:) = filter_data(data,'short',[],'congruent','sizes','falsefont');
vars(2,:) = filter_data(data,'medium',[],'congruent','sizes','falsefont');
vars(3,:) = filter_data(data,'tall',[],'congruent','sizes','falsefont');
vars(4,:) = filter_data(data,'short',[],'incongruent','sizes','falsefont');
vars(5,:) = filter_data(data,'medium',[],'incongruent','sizes','falsefont');
vars(6,:) = filter_data(data,'tall',[],'incongruent','sizes','falsefont');
vars(7,:) = filter_data(data,'short',[],'congruent','sizes','font');
vars(8,:) = filter_data(data,'medium',[],'congruent','sizes','font');
vars(9,:) = filter_data(data,'tall',[],'congruent','sizes','font');
vars(10,:) = filter_data(data,'short',[],'incongruent','sizes','font');
vars(11,:) = filter_data(data,'medium',[],'incongruent','sizes','font');
vars(12,:) = filter_data(data,'tall',[],'incongruent','sizes','font');
make_params(vars,'means',1); % shorts are pulling false fonts down, mediums are pulling fonts up
plot([1 1]*3.5, ylim, ':k');
plot([1 1]*9.5, ylim, ':k');
%plot(xlim, [1 1]*710, ':k');
plot([1 1]*6.5, ylim, '--k'); hold off
saveas(gcf,'size-discrepency-sizefirst','bmp')

clear vars;
vars(1,:) = filter_data(data,'short','red','congruent','sizes','font');
vars(2,:) = filter_data(data,'medium','red','congruent','sizes','font');
vars(3,:) = filter_data(data,'tall','red','congruent','sizes','font');
vars(4,:) = filter_data(data,'short','blue','congruent','sizes','font');
vars(5,:) = filter_data(data,'medium','blue','congruent','sizes','font');
vars(6,:) = filter_data(data,'tall','blue','congruent','sizes','font');
vars(7,:) = filter_data(data,'short','green','congruent','sizes','font');
vars(8,:) = filter_data(data,'medium','green','congruent','sizes','font');
vars(9,:) = filter_data(data,'tall','green','congruent','sizes','font');
make_params(vars,'means',1); % shorts are pulling false fonts down, mediums are pulling fonts up
% plot([1 1]*3.5, ylim, ':k');
% plot([1 1]*9.5, ylim, ':k');
% %plot(xlim, [1 1]*710, ':k');
% plot([1 1]*6.5, ylim, '--k'); hold off
saveas(gcf,'size-discrepency-sizefirst','bmp')

clear vars;
vars(1,:) = filter_data(data,'short',[],'congruent','colour','falsefont');
vars(2,:) = filter_data(data,'medium',[],'congruent','colour','falsefont');
vars(3,:) = filter_data(data,'tall',[],'congruent','colour','falsefont');
vars(4,:) = filter_data(data,'short',[],'incongruent','colour','falsefont');
vars(5,:) = filter_data(data,'medium',[],'incongruent','colour','falsefont');
vars(6,:) = filter_data(data,'tall',[],'incongruent','colour','falsefont');
vars(7,:) = filter_data(data,'short',[],'congruent','colour','font');
vars(8,:) = filter_data(data,'medium',[],'congruent','colour','font');
vars(9,:) = filter_data(data,'tall',[],'congruent','colour','font');
vars(10,:) = filter_data(data,'short',[],'incongruent','colour','font');
vars(11,:) = filter_data(data,'medium',[],'incongruent','colour','font');
vars(12,:) = filter_data(data,'tall',[],'incongruent','colour','font');
make_params(vars,'means',1); % shorts are pulling false fonts down, mediums are pulling fonts up
plot([1 1]*3.5, ylim, ':k');
plot([1 1]*9.5, ylim, ':k');
%plot(xlim, [1 1]*710, ':k');
plot([1 1]*6.5, ylim, '--k'); hold off
saveas(gcf,'size-by-colour','bmp')





