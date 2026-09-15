function eventList = addEvent(trialEntry,cfg)

cfg = checkCfg(cfg); % check input data and requestes fields

eventList.cfg = rmfield(cfg,'inputFields');
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
        entryTimes = eventTimes(entryFlags) - trials(ientry).startTime;
        
        % count events. 
        trials(ientry).([eventRequest{ievent} 'Count']) = numel(entryTimes);

        % compute event latency if requested
        if cfg.latency
            trials(ientry).([eventRequest{ievent} 'Times']) = entryTimes;
        end

        % extract first event if requested
        if cfg.firstEvent
            firstEvent  = min(entryTimes);
            if isempty(firstEvent); firstEvent = NaN; end
            trials(ientry).([eventRequest{ievent} 'First']) = firstEvent;
        end
        
    end
end

eventList.trials = trials;

function cfg = checkCfg(cfg)

cfg.inputFields = {'latency','firstEvent'};

for iField = 1:numel(cfg.inputFields)
    localField = cfg.inputFields{iField};
    if ~isfield(cfg,localField)
        cfg.(localField) = false;
    end
end