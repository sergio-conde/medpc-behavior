function ev = ev_count(cfg)

% check whether med_data is a path, a struct (i.e, after using read_medpc
% independently) or a vector (the event and time blocks)

%%%% Check input struct %%%%%%%%%%%%%%%%%%
if isfield(cfg,'med_data')
    med_data = get_med_data(cfg.med_data);
else
    error_handle(0)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ev.cfg = cfg;
ev_labels = fieldnames(cfg.events);
for iev = 1:length(ev_labels)
    ev_id     = cfg.events.(ev_labels{iev});
    ev_flags  = med_data.E == ev_id;

    ev.(ev_labels{iev}).count       = sum(ev_flags);
    ev.(ev_labels{iev}).timestamps  = med_data.D(ev_flags) * 10e-3;
end

function med_data = get_med_data(med_data_in)
    if ischar(med_data_in)
        med_data = read_medpc(med_data_in);
    elseif isstruct(med_data_in) % not any struct! include some output from read_medpc so I can identify that is the correct struct
        % if med_str_chk(med_data_in)
        med_data = med_data_in;
        % else
        % error_handle(2)
        % end
    else
        error_handle(1)
    end


function error_handle(error_id)
switch error_id
    case 0
        fprintf('\n')
        error('Input structure must contain a med_data field')
    case 1
        fprintf('\n')
        error('med_data field must contain either a path or a struct')
    case 2
        fprintf('\n')
        error('med_data struct is uncompatible')
end