function eventList = addEvent(trialEntry,cfg)

if ~isfield(cfg,'latency')
    cfg.latency = false;
end

if ~isfield(cfg,'firstEvent')
    cfg.firstEvent = false;
end

eventList.cfg = cfg;
eventList.dataCfg = trialEntry.cfg;
eventList.medData = trialEntry.medData;

trials = trialEntry.trials;
eventRequest = cfg.events;

for ievent = 1:length(eventRequest)
    eventFlags = eventList.medData.E == trialEntry.cfg.events.(eventRequest{ievent});
    eventTimes = eventList.medData.D(eventFlags) * 10e-3;
    for ientry = 1:size(trials,1)
        
        entryFlags = eventTimes >= trials(ientry).startTime & ...
            eventTimes < trials(ientry).endTime;
        entryTimes = eventTimes(entryFlags);
        trials(ientry).([eventRequest{ievent} 'Count']) = length(entryTimes);

        if cfg.latency
            trials(ientry).([eventRequest{ievent} 'Time']) = entryTimes;
        end

        if cfg.firstEvent
            firstEvent  = min(entryTimes - trials(ientry).startTime);
            if isempty(firstEvent); firstEvent = NaN; end
            trials(ientry).([eventRequest{ievent} 'First']) = firstEvent;
        end
    end
end

eventList.trials = trials;