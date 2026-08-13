function ev_struct = addEvent(trialEntry,cfg)

if ~isfield(cfg,'latency')
    cfg.latency = false;
end

if ~isfield(cfg,'first_lat')
    cfg.first_lat = false;
end

ev_struct.cfg          = cfg;
ev_struct.data_cfg     = trialEntry.cfg;
ev_struct.med_data     = trialEntry.med_data;

trials    = trialEntry.trials;
eventList   = cfg.events;

for ievent = 1:length(eventList)
    eventFlags = ev_struct.med_data.E == trialEntry.cfg.events.(eventList{ievent});
    eventTimes = ev_struct.med_data.D(eventFlags) * 10e-3;
    for ientry = 1:size(trials,1)
        
        entryFlags = eventTimes >= trials(ientry).startTime & ...
            eventTimes < trials(ientry).endTime;
        entryTimes = eventTimes(entryFlags);
        first_ev  = min(entryTimes - trials(ientry).startTime);
        if isempty(first_ev); first_ev = NaN; end

        trials(ientry).([eventList{ievent} '_num']) = length(entryTimes);

        if cfg.latency
            trials(ientry).([eventList{ievent} '_tstamp']) = entryTimes;
        end

        if cfg.first_lat
            trials(ientry).([eventList{ievent} '_lat1']) = first_ev;
        end
    end
end

ev_struct.trials = trials;