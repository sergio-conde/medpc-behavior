%% MedPC output analysis example
% 
% 
% This is an example of how to use the toolbox to do exploratory behavioral 
% analysis from the MedPC output file. 

clear; clc
% ref_file = 'M:\GitHub\medpc-behavior\example_data\example_rat_multipellet';
refFile = 'C:\Work\GitHub\medpc-behavior\example_data\example_rat_multipellet';
% med_data = read_medpc(ref_file);

% Configuration
% We start by defining a configuration struct. So far, this struct must have 
% at least the following fields:
% % 
% * _*med_file*_: full path of the file to be analyzed [char]

cfg           = [];
cfg.medFile  = refFile;
% % 
% * _*events*_: this field contains as many fields as events you want to include 
% in the analysis. It can iclude, for example, cues, outcomes, levers, trial start, 
% etc. You can define the name os thse fields on your convenience. 

% FSCV_Conflict_01 % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \ E = Event identity time stamps
cfg.events.sessStart = 1;    % \ 1 - Session start
cfg.events.cue1On    = 2;    % \ 2 - Cue1p ON
cfg.events.cue1Off   = 3;    % \ 3 - Cue1p OFF
cfg.events.cue4On    = 4;    % \ 4 - Cue4p ON
cfg.events.cue4Off   = 5;    % \ 5 - Cue4p OFF
cfg.events.anyPellet = 6;    % \ 6 - Any Pellet
cfg.events.drop1p    = 7;    % \ 7 - 1p Pellet drop
cfg.events.drop4p    = 8;    % \ 8 - 4p first pellet
cfg.events.irLightOn = 9;    % \ 9 - IR light ON
cfg.events.magCue1   = 10;   % \ 10 - Mag during 1p Cue
cfg.events.magCue4   = 11;   % \ 11 - Mag during 4p Cue
cfg.events.subs4p    = 12;   % \ 12 - 4p subsequent pellets
cfg.events.mag       = 16;   % \ 16 - Mag entry any time
cfg.events.sessEnd   = 100;  % \ 100 - End of session
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% * _*trial*_: which has felds defining the key events. These include events 
% that mark the start and the end of the trial

cfg.trial.trialLabel = {'1p','4p'};
cfg.trial.start      = {'cue1On','cue4On'};
cfg.trial.end        = {'cue1Off','cue4Off'};

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

evConfig.events  = {'magCue1','magCue4','mag'};
% sel_events  = {'mag'};
eventList   = addEvent(trial_struct,evConfig);
% Extract data of interest

clear eventSel
entry                 = [];
entry.count           = [7 12];
entry.contrast.count  = 'range';
entry.interval        = 'trial';
[eventSel,requestConfig] = getEntry(eventList.trials,entry);

%%
% Extract data of interest

data1pTrial  = getEntry(eventList.trials,'trialLabel','1p','interval','trial');
data1pIti = getEntry(eventList.trials,'trialLabel','1p','interval','iti');

data4pTrial  = getEntry(eventList.trials,'trialLabel','4p','interval','trial');
data4pIti = getEntry(eventList.trials,'trialLabel','4p','interval','iti');

% Plot some results

boxData  = [[data1pTrial.magCue1Count] [data1pIti.magCue1Count] ...
    [data4pTrial.magCue4Count] [data4pIti.magCue4Count]];
groupId     = [ones(1,length(data1pTrial)) 2*ones(1,length(data1pIti)) ...
    3*ones(1,length(data_4p_tr)) 4*ones(1,length(data4pIti))];

wfig(1)

subplot 121
boxplot(boxData,groupId)
box off; ylabel '# mag (1p / 4p) entries'
xticklabels({'cue1p','iti1p','cue4p','iti4p'})

boxData  = [[data1pTrial.magCount] [data1pIti.magCount] ...
    [data4pTrial.magCount] [data4pIti.magCount]];
subplot 122
boxplot(boxData,groupId)
box off; ylabel '# mag (any) entries'
xticklabels({'cue1p','iti1p','cue4p','iti4p'})

