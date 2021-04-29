%% Stroop task
% Dorian Minors
% Created: JAN21
% Last Edit: APR21
% hasty work around some NI card reservation error from scansync
% NOTE: please be careful you don't overwrite things by running proc gen
% and stroop together - as of 28APR, this is fine.
%% set up

close all;
clearvars;
clc;

p = struct(); % est structure for parameter values
d = struct(); % est structure for trial data
t = struct(); % another structure for untidy temp floating variables

rootdir = pwd; % root directory - used to inform directory mappings
p.vocal_stroop = 1; 
p.manual_stroop = 0;

addpath(genpath(fullfile(rootdir, 'lib'))); % add tools folder to path
stimdir = fullfile(rootdir, 'lib', 'stimuli');
datadir = fullfile(rootdir, 'data'); % will make a data directory if none exists
if ~exist(datadir,'dir'); mkdir(datadir); end

t.prompt = 'participant number [99]?  ';
d.participant_id = input(t.prompt);
if isempty(d.participant_id); d.participant_id = 99; end
t.prompt = 'generate procedures (y/[n])?  ';
t.generate = input(t.prompt,'s');
if isempty(t.generate) || strcmp(t.generate,'n'); t.generate = 0; else t.generate = 1; end
t.prompt = 'which procedure [1]?  ';
p.procedure_index = input(t.prompt);
if isempty(p.procedure_index); p.procedure_index = 1; end
t.prompt = 'do a practice (y/[n])?  ';
p.practice = input(t.prompt,'s');
if isempty(p.practice) || strcmp(p.practice,'n'); p.practice = 0; else p.practice = 1; end

if t.generate; Procedure_Gen(p,d,rootdir,stimdir,datadir); end
[p,d] = Stroop(p,d,rootdir,stimdir,datadir);

disp('all procedures: ');
disp(d.all_procedure_codes);
fprintf('you just completed procedure %1.0f\n',p.procedure_index);
fprintf('stimulus type: %s\n',d.stimulus_type);
fprintf('with attended feature: %s\n',d.attended_feature);
