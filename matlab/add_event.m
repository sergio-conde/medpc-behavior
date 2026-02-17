function ev_struct = add_event(trial_struct,cfg)

if ~isfield(cfg,'latency')
    cfg.latency = false;
end

if ~isfield(cfg,'first_lat')
    cfg.latency = false;
end

ev_struct.cfg          = cfg;
ev_struct.data_cfg     = trial_struct.cfg;
ev_struct.med_data     = trial_struct.med_data;

trials    = trial_struct.trials;
ev_list   = cfg.events;

for ievent = 1:length(ev_list)
    ev_flags = ev_struct.med_data.E == trial_struct.cfg.events.(ev_list{ievent});
    ev_times = ev_struct.med_data.D(ev_flags) * 10e-3;
    for iint = 1:size(trials,1)
        
        int_flags = ev_times >= trials(iint).t_start & ev_times < trials(iint).t_end;
        int_times = ev_times(int_flags);
        first_ev  = min(int_times - trials(iint).t_start);
        if isempty(first_ev); first_ev = NaN; end

        trials(iint).([ev_list{ievent} '_num']) = length(int_times);

        if cfg.latency
            trials(iint).([ev_list{ievent} '_tstamp']) = int_times;
        end

        if cfg.first_lat
            trials(iint).([ev_list{ievent} '_lat1']) = first_ev;
        end
    end
end

ev_struct.trials = trials;