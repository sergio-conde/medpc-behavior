function event = extractEvent(cfg)

% check whether med_data is a path, a struct (i.e, after using read_medpc
% independently) or a vector (the event and time blocks)

% It assumes the sample rate is 100Hz

% Medpc-Behavior project. 
% Sergio Conde-Ocazionez, August 2026. 
% Neuromodulation & Behavior Laboratory
% Netherlands Institute for Neuroscience.

SRATE = 100; % Hz

%%%% Check input struct %%%%%%%%%%%%%%%%%%
if isfield(cfg,'medData')
    medData = checkMedData(cfg.medData);
    if medData.errorFlag
        errorHandle(1)
    end
elseif isfield(cfg,'medFile')
    medData = read_medpc(medDataIn);
else
    errorHandle(0)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

event.cfg = cfg;
eventLabels = fieldnames(cfg.events);
for ievent = 1:length(eventLabels)
    currentEvent = eventLabels{ievent};
    eventID = cfg.events.(currentEvent);
    eventFlags = medData.E == eventID;
    event.(currentEvent).count = sum(eventFlags);
    event.(currentEvent).timestamps = medData.D(eventFlags) / SRATE;
end

function checkMedData(medData)




function errorHandle(errorID)
switch errorID
    case 0
        fprintf('\n')
        error('Input structure must contain at least a medData or medFile field')
    case 1
        fprintf('\n')
        error('medData must be formatted as the output of readMedpc function')
    case 2
        fprintf('\n')
        error('med_data struct is uncompatible')
end