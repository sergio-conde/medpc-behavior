function ev = ev_count(cfg)

ev.cfg = cfg;

med_data = read_medpc(cfg.med_file);

ev_labels = fieldnames(cfg.events);
for iev = 1:length(ev_labels)
    ev_id     = cfg.events.(ev_labels{iev});
    ev_flags  = med_data.E == ev_id;

    ev.(ev_labels{iev}).count       = sum(ev_flags);
    ev.(ev_labels{iev}).timestamps  = med_data.D(ev_flags) * 10e-3;
end

