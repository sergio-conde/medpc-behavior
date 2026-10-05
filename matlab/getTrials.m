
function trialStruct = getTrials(cfg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trialStruct = getTrials(cfg)
%
% getTrials extracts the trials contained in MedPC files 
% following the user's configuration 
%
% Inputs:
% cfg: configuration struct containing the following fields                 [struct]
%   medFile: MedPC output file. It can be a string with the full path
%   of the file, or the output of the readMedpc function.
% 
%   events: struct with fields named after each event and contining the
%   number used to configure each event in the MedPC
%   trialStart: name(s) of the events in the events field used to mark the
%   start of the trial
%   trialEnd: name(s) of the events used to mark the end of the trial
%   (optional, default: next trialStart; then events.sessionEnd is required)
%   trialLabel: label of each trialStart event (optional)
%   medTime: block with event times (optional, default: 'D')
%   medEvents: block with event codes (optional, default: 'E')
% 
% Outputs:
%   trialStruct: struct with fields cfg, medData and trials. trials contains
%   the following fields:
%   * trialLabel: trial type, which is defined by the trialLabel field of the
%     trial configuration (only if cfg.trialLabel is given).
%   * interval: interval label. This could be either _trial_ or _iti_ 
%   * trialStart: label of the event that starts the interval
%   * trialEnd: label of the event that ends the interval
%   * count: trial number
%   * startTime: start time in seconds
%   * endTime: end time in seconds
%   * duration: in seconds

% Sergio Conde-Ocazionez, August 2024.
% v0.2 August 2026
% Neuromodulation & Behavior Laboratory
% Netherlands Institute for Neuroscience.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MEDSAMPLERATE = 10e-3;

%---------------------- check the medFile input ----------------------------%
if ischar(cfg.medFile)
    medData = readMedpc(cfg.medFile);
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

if ~iscell(cfg.trialStart)
    cfg.trialStart = eventList(ismember(idList,cfg.trialStart));
end

if ~isfield(cfg,'trialEnd')
    cfg.trialEnd = cfg.trialStart;
    noEndFlag = 1;
else
    if ~iscell(cfg.trialEnd)
        cfg.trialEnd = eventList(ismember(idList,cfg.trialEnd));
    end
    noEndFlag = 0;
end

if ~isfield(cfg,'medTime')
    cfg.medTime = 'D';
end
medTime = medData.(cfg.medTime);

if ~isfield(cfg,'medEvents')
    cfg.medEvents = 'E';
end
medEvents = medData.(cfg.medEvents);

trialStruct.cfg     = cfg;
trialStruct.medData = medData;

%---------------------- start event compilation ----------------------------%
startEvent = cfg.trialStart;
startTimes = [];
startIds   = [];
for ievent = 1:length(startEvent)
    eventId = cfg.events.(cfg.trialStart{ievent});
    startTimes = cat(2,startTimes,medTime(medEvents == eventId));
    startIds   = cat(2,startIds,ievent * ones(1,sum(medEvents == eventId)));
end
[~, sortSample] = sort(startTimes);
sortStartIds = startIds(sortSample);
sortStartLabel = cfg.trialStart(startIds);
%---------------------- start event compilation ----------------------------%

%------------------------ end event compilation ----------------------------%
endEvent    = cfg.trialEnd;
endTimes = [];
endIds   = [];

for ievent = 1:length(endEvent)
    eventId  = cfg.events.(cfg.trialEnd{ievent});
    endTimes = cat(2,endTimes,medTime(medEvents == eventId));
    endIds   = cat(2,endIds,ievent * ones(1,sum(medEvents == eventId)));
end
sortEndLabel = cfg.trialEnd(endIds);
%------------------------ end event compilation ----------------------------%

if noEndFlag
    endTime = medTime(medEvents == cfg.events.sessionEnd);
    endTimes = [endTimes(2:end) endTime] - 1;
end
intervalTimes = [startTimes endTimes] * MEDSAMPLERATE;

[sortTimes, sortIds] = sort(intervalTimes);
sortLabels = [sortStartLabel sortEndLabel];
sortLabels = sortLabels(sortIds)';

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

intervalFields = {'interval','trialStart','trialEnd','count', ...
        'startTime','endTime','duration'};

if isfield(cfg,'trialLabel')
    trialIds = cell(size(intervalTimes,1),1);
    trialIds(intervalStart == 1) = cfg.trialLabel(sortStartIds);
    trialIds(intervalStart == 0) = trialIds(find(intervalStart == 0) - 1);
    intervalCell = [trialIds intervalCell];
    intervalFields = ['trialLabel',intervalFields];
end
trialStruct.trials = cell2struct(intervalCell,intervalFields,2);
if noEndFlag
    trialStruct.trials = getEntry(trialStruct.trials,'interval','trial');
end


