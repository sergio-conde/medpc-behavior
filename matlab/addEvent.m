function eventList = addEvent(trialEntry,cfg)

MEDSAMPLERATE = 10e-3;

cfg = checkCfg(cfg); % check input data and requestes fields

eventList.cfg = rmfield(cfg,'inputFields');
eventList.dataCfg = trialEntry.cfg;
eventList.medData = trialEntry.medData;

medTime = trialEntry.medData.(trialEntry.cfg.medTime);
medEvents = trialEntry.medData.(trialEntry.cfg.medEvents);

trials = trialEntry.trials;
eventRequest = cfg.events;

for ievent = 1:length(eventRequest)
    eventLabel = eventRequest{ievent};
    eventFlags = medEvents == trialEntry.cfg.events.(eventLabel);
    eventTimes = medTime(eventFlags) * MEDSAMPLERATE;
    for ientry = 1:size(trials,1)
        
        entryFlags = eventTimes >= trials(ientry).startTime & ...
            eventTimes < trials(ientry).endTime;
        entryTimes = eventTimes(entryFlags) - trials(ientry).startTime;
        
        % count events. 
        trials(ientry).([eventLabel 'Count']) = numel(entryTimes);

        % compute event latency if requested
        if cfg.latency
            trials(ientry).([eventLabel 'Times']) = entryTimes;
        end

        % extract first event if requested
        if cfg.firstEvent
            firstEvent  = min(entryTimes);
            if isempty(firstEvent); firstEvent = NaN; end
            trials(ientry).([eventLabel 'First']) = firstEvent;
        end

        % extract event bouts
        if isfield(cfg,'bouts') && ~isempty(entryTimes)
            boutList = extractBouts(entryTimes, ...
                cfg.bouts.minInterval(ievent), ...
                cfg.bouts.minDuration(ievent));
            nBouts = height(boutList);
            
            trials(ientry).([eventLabel 'Bouts']) = nBouts;
            trials(ientry).([eventLabel 'BoutStart']) = boutList.boutStart;
            trials(ientry).([eventLabel 'BoutEnd']) = boutList.boutEnd;
            trials(ientry).([eventLabel 'BoutDuration']) = boutList.duration;
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