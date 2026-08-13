%% MedPC output analysis example
% 
% 
% This is an example of how to use the toolbox to do exploratory behavioral 
% analysis from the MedPC output file. 

clear; clc
% ref_file = 'M:\GitHub\medpc-behavior\example_data\example_rat_multipellet';
ref_file = 'C:\Work\GitHub\medpc-behavior\example_data\example_rat_multipellet';
% med_data = read_medpc(ref_file);

% Configuration
% We start by defining a configuration struct. So far, this struct must have 
% at least the following fields:
% % 
% * _*med_file*_: full path of the file to be analyzed [char]

cfg           = [];
cfg.med_file  = ref_file;
% % 
% * _*events*_: this field contains as many fields as events you want to include 
% in the analysis. It can iclude, for example, cues, outcomes, levers, trial start, 
% etc. You can define the name os thse fields on your convenience. 

% FSCV_Conflict_01 % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \ E = Event identity time stamps
cfg.events.sess_start = 1;    % \ 1 - Session start
cfg.events.cue1_on    = 2;    % \ 2 - Cue1p ON
cfg.events.cue1_off   = 3;    % \ 3 - Cue1p OFF
cfg.events.cue4_on    = 4;    % \ 4 - Cue4p ON
cfg.events.cue4_off   = 5;    % \ 5 - Cue4p OFF
cfg.events.any_p      = 6;    % \ 6 - Any Pellet
cfg.events.drop_1p    = 7;    % \ 7 - 1p Pellet drop
cfg.events.drop_4p    = 8;    % \ 8 - 4p first pellet
cfg.events.ir_on      = 9;    % \ 9 - IR light ON
cfg.events.mag_cue1   = 10;   % \ 10 - Mag during 1p Cue
cfg.events.mag_cue4   = 11;   % \ 11 - Mag during 4p Cue
cfg.events.subs_4p    = 12;   % \ 12 - 4p subsequent pellets
cfg.events.mag        = 16;   % \ 16 - Mag entry any time
cfg.events.sess_end   = 100;  % \ 100 - End of session
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% * _*trial*_: which has felds defining the key events. These include events 
% that mark the start and the end of the trial

cfg.trial.trialLabel = {'1p','4p'};
cfg.trial.start      = {'cue1_on','cue4_on'};
cfg.trial.end        = {'cue1_off','cue4_off'};

% Create main trial structure
% We can use that configuration to create the main trial structure. This struct 
% organizes choronologicaly the trials and ITIs. The trials are defined by start-end 
% pairs. The ITI are defined from the end event of the trial and the start event 
% of the next trial (or end of the session in case of the last trial).
% 

%% 
% This struct is the backbone of the analysis. The times listed in this structure 
% will be the reference to the trial based analysis: counting behavioral events, 
% latencies, etc.

trial_struct = getTrials(cfg);
% Add selected variables (from the cfg.events)
% After having the main trial struct, you can add behavioral variables (events) 
% to that structure by listing the field names defined in the event configuration 
% and corresponding to the variables of your interest. In this example, we are 
% adding the 'mag' variable, which indicates a maganize entry. 

evConfig.events  = {'mag_cue1','mag_cue4','mag'};
% sel_events  = {'mag'};
ev_struct   = addEvent(trial_struct,evConfig);
% Extract data of interest

clear out_files
entry                 = [];
entry.count           = [7 12];
entry.contrast.count  = 'range';
entry.interval        = 'trial';
[out_files,requestConfig] = getEntry(ev_struct.trials,entry);

%%
% Extract data of interest

data_1p_tr  = getEntry(ev_struct.trials,'trialLabel','1p','interval','trial');
data_1p_iti = getEntry(ev_struct.trials,'trialLabel','1p','interval','iti');

data_4p_tr  = getEntry(ev_struct.trials,'trialLabel','4p','interval','trial');
data_4p_iti = getEntry(ev_struct.trials,'trialLabel','4p','interval','iti');

% Plot some results

box_data  = [[data_1p_tr.mag_cue1_num] [data_1p_iti.mag_cue1_num] ...
    [data_4p_tr.mag_cue4_num] [data_4p_iti.mag_cue4_num]];
gr_id     = [ones(1,length(data_1p_tr)) 2*ones(1,length(data_1p_iti)) ...
    3*ones(1,length(data_4p_tr)) 4*ones(1,length(data_4p_iti))];

wfig(1)

subplot 121
boxplot(box_data,gr_id)
box off; ylabel '# mag (1p / 4p) entries'
xticklabels({'cue1p','iti1p','cue4p','iti4p'})

box_data  = [[data_1p_tr.mag_num] [data_1p_iti.mag_num] [data_4p_tr.mag_num] [data_4p_iti.mag_num]];
subplot 122
boxplot(box_data,gr_id)
box off; ylabel '# mag (any) entries'
xticklabels({'cue1p','iti1p','cue4p','iti4p'})

