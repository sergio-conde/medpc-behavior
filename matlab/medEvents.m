function medBehavior = medEvents(cfg)

cfg = checkCfg(cfg);
cfg.data = readMedpc(cfg.file);
medBehavior.cfg = cfg;
medBehavior.sequence = cfg.data.(cfg.medEvents);
medBehavior.eventTimes = cfg.data.(cfg.medTime) * 1e-2; % medpc resolution is 10ms

eventLabels = fieldnames(cfg.events);
for ievent = 1:numel(eventLabels)
    localEvent = eventLabels{ievent};   % event label
    eventFlags = medBehavior.sequence == medBehavior.cfg.events.(localEvent);

    if any(eventFlags)
        eventTimes = medBehavior.eventTimes(eventFlags);
        medBehavior.trigger.(localEvent) = find(eventFlags);
        medBehavior.timeStamps.(localEvent) = eventTimes;

        if ismember(localEvent,cfg.boutEvents.boutLabels)  
            boutList = extractBouts(eventTimes, ...
                cfg.boutEvents.(localEvent).interBout, ...
                cfg.boutEvents.(localEvent).minBoutDur);
            medBehavior.bout.(localEvent).start = boutList.boutStart;
            medBehavior.bout.(localEvent).duration = boutList.duration;
            medBehavior.bout.(localEvent).triggCount = boutList.triggCount;
        end
    else
        medBehavior = addDefaults(medBehavior,localEvent);
    end
end
medBehavior.fileType = 'medpc';

function medBehavior = addDefaults(medBehavior,localEvent)
medBehavior.trigger.(localEvent) = [];
medBehavior.timeStamps.(localEvent) = [];
medBehavior.bout.(localEvent).start = [];
medBehavior.bout.(localEvent).duration = [];
medBehavior.bout.(localEvent).triggCount = [];

function cfg = checkCfg(cfg)

if ~isfield(cfg,'medTime')
    cfg.medTime = 'D';
end

if ~isfield(cfg,'medEvents')
    cfg.medEvents = 'E';
end

if isfield(cfg,'boutEvents')
    cfg.boutEvents.boutLabels = fieldnames(cfg.boutEvents);
else
    cfg.boutEvents.boutLabels = {};
end
