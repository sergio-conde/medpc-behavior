function ev = ev_count(cfg)

% check whether med_data is a path, a struct (i.e, after using read_medpc
% independently) or a vector (the event and time blocks)

%%%% Check input struct %%%%%%
if isfield(cfg,'med_data')
    
else
    error_handle(0)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ev.cfg = cfg;

med_data = read_medpc(cfg.med_file);

ev_labels = fieldnames(cfg.events);
for iev = 1:length(ev_labels)
    ev_id     = cfg.events.(ev_labels{iev});
    ev_flags  = med_data.E == ev_id;

    ev.(ev_labels{iev}).count       = sum(ev_flags);
    ev.(ev_labels{iev}).timestamps  = med_data.D(ev_flags) * 10e-3;
end

function error_handle(error_id)

switch error_id
    case 0
        fprintf('\n')
        error('Input structure must contain a med_data field')
    otherwise
end