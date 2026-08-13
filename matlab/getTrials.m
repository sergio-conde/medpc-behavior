
function trialStruct = getTrials(cfg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trial_struct = getTrials(cfg)
%
% get_trials function extracts the trials contained in med_pc files 
% following the user's configuration 
%
% Inputs:
% cfg: configuration struct containing the following fields                 [struct]
%   med_file: MedPC output file. It can be a string with the full path
%   of the file, or the output of the read_medpc function.
% 
%   events: struct with fields named after each event and contining the
%   number used to configure each event in the MedPC
%   start_label: label of the events used to mark the start of the trial
%   start: name of the events in the events field used to mark the start of 
%   the trial
%   end: name of the events used to mark the end of the trial
% 
% Outputs:
%   This struct contains the following fields:
%   * type: trial type, which is defined by the strat_label field of the trial 
%     configuration. 
%   * num: trial number
%   * t_start: start time in seconds
%   * t_end: end time in seconds
%   * duration: in seconds
%   * int_label: interval label. This could be either _trial_ or _iti_% 
%
% Sergio Conde-Ocazionez, August 2024.
% v0.2 August 2026
% Neuromodulation & Behavior Laboratory
% Netherlands Institute for Neuroscience.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------- check the med_file input ----------------------------%
if ischar(cfg.medFile)
    medData = read_medpc(cfg.medFile);
elseif isstruct(cfg.medFile)
    % include here something to check if the struct has the right configuration
    medData = cfg.medFile;
end

% include defaults for different med_pc configurations, like sample rate

% the medpc output files have the D block which contains the sample number
% of the ocurrence of each event. This way, the actual time would be sample
% * 10e-3

eventList = fieldnames(cfg.events);
idList = [];
for iev = 1:length(eventList)
    idList = cat(2,idList,cfg.events.(eventList{iev}));
end

if ~iscell(cfg.trial.start)
    cfg.trial.start = eventList(ismember(idList,cfg.trial.start));
end

if ~iscell(cfg.trial.end)
    cfg.trial.end = cfg.trial.start;
    noEndFlag = 1;
else
    if ~iscell(cfg.trial.end)
        cfg.trial.end = eventList(ismember(idList,cfg.trial.end));
    end
    noEndFlag = 0;
end

trialStruct.cfg     = cfg;
trialStruct.medData = medData;

%---------------------- start event compilation ----------------------------%
startEvent = cfg.trial.start;
startTimes = [];
startIds   = [];
for ievent = 1:length(startEvent)
    eventId = cfg.events.(cfg.trial.start{ievent});
    startTimes = cat(2,startTimes,medData.D(medData.E == eventId));
    startIds   = cat(2,startIds,ievent * ones(1,sum(medData.E == eventId)));
end
[~, sortSample] = sort(startTimes);
sortStartIds = startIds(sortSample);
sortStartLabel = cfg.trial.start(startIds);
%---------------------- start event compilation ----------------------------%

%------------------------ end event compilation ----------------------------%
endEvent    = cfg.trial.end;
endTimes = [];
endIds   = [];

for ievent = 1:length(endEvent)
    eventId  = cfg.events.(cfg.trial.end{ievent});
    endTimes = cat(2,endTimes,medData.D(medData.E == eventId));
    endIds   = cat(2,endIds,ievent * ones(1,sum(medData.E == eventId)));
end
sortEndLabel = cfg.trial.end(endIds);
%------------------------ end event compilation ----------------------------%

if noEndFlag
    intervalTimes = [startTimes endTimes(2:end)] * 10e-3;
else
    intervalTimes = [startTimes endTimes] * 10e-3;
end

[sortTimes, sortIds]  = sort(intervalTimes);
sortLabels            = [sortStartLabel sortEndLabel];
sortLabels            = sortLabels(sortIds)';

startEventLabels = sortLabels(1:end - 1);
endEventLabels = sortLabels(2:end);

intervalTimes = [sortTimes(1:end - 1); sortTimes(2:end)]';
duration = diff(intervalTimes,1,2);

intervalIds = [ones(1,length(startTimes)) zeros(1,length(endTimes))];
intervalStart = intervalIds(sortIds(1:end - 1))';

trialLabels = cell(length(intervalIds) - 1,1);
trialLabels(intervalStart == 1) = {'trial'};
trialLabels(intervalStart == 0) = {'iti'};

intervalCount = zeros(size(intervalTimes,1),1);
intervalCount(intervalStart == 1) = 1:sum(intervalStart == 1);
intervalCount(intervalStart == 0) = intervalCount(find(intervalStart == 0) - 1);

intervalInfo = [intervalCount intervalTimes duration];
intervalCell = [trialLabels startEventLabels endEventLabels num2cell(intervalInfo)];

if isfield(cfg.trial,'trialLabel')
    trialIds = cell(size(intervalTimes,1),1);
    trialIds(intervalStart == 1) = cfg.trial.trialLabel(sortStartIds);
    trialIds(intervalStart == 0) = trialIds(find(intervalStart == 0) - 1);
    intervalCell = [trialIds intervalCell];

    intervalFields = {'trialLabel','interval','trialStart','trialEnd','count', ...
        'startTime','endTime','duration'};
else
    intervalFields = {'interval','trialStart','trialEnd','count', ...
        'startTime','endTime','duration'};
end

trialStruct.trials = cell2struct(intervalCell,intervalFields,2);

