function medBehavior = medEvents(cfg)

cfg = checkCfg(cfg);

medBehavior.cfg = cfg;
medBehavior.sequence = cfg.data.(cfg.medEvents);
medBehavior.timeAxis = cfg.data.(cfg.medTime) * 1e-2; % medpc resolution is 10ms

eventLabels = fieldnames(cfg.events);
for ievent = 1:numel(eventLabels)
    localEvent = eventLabels{ievent};   % event label
    eventFlags = medBehavior.sequence == medBehavior.cfg.events.(localEvent);

    if any(eventFlags)
        eventTimes = medBehavior.timeAxis(eventFlags);
        medBehavior.trigger.(localEvent) = find(eventFlags);
        medBehavior.trigTime.(localEvent) = eventTimes;

        if ismember(localEvent,cfg.boutEvents.boutLabels)  
            boutList = extractBouts(eventTimes, ...
                cfg.boutEvents.(localEvent).interBout, ...
                cfg.boutEvents.(localEvent).minBoutDur);
            medBehavior.time.(localEvent).start  = boutList.boutStart;
            medBehavior.time.(localEvent).duration = boutList.duration;
            medBehavior.time.(localEvent).triggCount = boutList.triggCount;
        end
    else
        medBehavior = addDefaults(medBehavior,localEvent);
    end
end
medBehavior.fileType = 'medpc';


function medBehavior = addDefaults(medBehavior,localEvent)
medBehavior.trigger.(localEvent) = [];
medBehavior.trigTime.(localEvent) = [];
medBehavior.time.(localEvent).start = [];
medBehavior.time.(localEvent).duration = [];
medBehavior.time.(localEvent).triggCount = [];


function cfg = checkCfg(cfg)
if ischar(cfg.data)
    cfg.data = readMedpc(cfg.data);
end

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
