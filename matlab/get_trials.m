
function trial_struct = get_trials(cfg)

med_data = read_medpc(cfg.med_file);

trial_struct.cfg      = cfg;
trial_struct.med_data = med_data;

% the medpc output files have the D block which contains the sample number
% of the ocurrence of each event. This way, the actual time would be sample
% * 10e-3

%---------------------- start event compilation ----------------------------%
start_ev    = cfg.trial.start;
start_times = [];
start_ids   = [];
for ievent = 1:length(start_ev)
    ev_id       = cfg.events.(cfg.trial.start{ievent});
    start_times = cat(2,start_times,med_data.D(med_data.E == ev_id));
    start_ids   = cat(2,start_ids,ievent * ones(1,sum(med_data.E == ev_id)));
end
[~, sort_sample]  = sort(start_times);
sort_start_ids    = start_ids(sort_sample);
sort_start_lab    = cfg.trial.start(start_ids);
%---------------------- start event compilation ----------------------------%

%------------------------ end event compilation ----------------------------%
end_ev    = cfg.trial.end;
end_times = [];
end_ids   = [];

for ievent = 1:length(end_ev)
    ev_id     = cfg.events.(cfg.trial.end{ievent});
    end_times = cat(2,end_times,med_data.D(med_data.E == ev_id));
    end_ids   = cat(2,end_ids,ievent * ones(1,sum(med_data.E == ev_id)));
end
% [~, sort_sample]  = sort(end_times);
% sort_end_ids      = end_ids(sort_sample);
sort_end_lab      = cfg.trial.end(end_ids);

%------------------------ end event compilation ----------------------------%

%%

tr_iti_times            = [start_times end_times] * 10e-3;
[sort_times, sort_ids]  = sort(tr_iti_times);
sort_labels             = [sort_start_lab sort_end_lab];
sort_labels             = sort_labels(sort_ids)';

start_ev_lab  = sort_labels(1:end - 1);
end_ev_lab    = sort_labels(2:end);

tr_interval = [sort_times(1:end - 1); sort_times(2:end)]';
duration    = diff(tr_interval,1,2);

tr_iti_ids  = [ones(1,length(start_times)) zeros(1,length(end_times))];
int_start   = tr_iti_ids(sort_ids(1:end - 1))';

tr_labels                 = cell(length(tr_iti_ids) - 1,1);
tr_labels(int_start == 1) = {'trial'};
tr_labels(int_start == 0) = {'iti'};

int_num                 = zeros(size(tr_interval,1),1);
int_num(int_start == 1) = 1:sum(int_start == 1);
int_num(int_start == 0) = int_num(find(int_start == 0) - 1);

tr_info   = [int_num tr_interval duration];
cell_base = [tr_labels start_ev_lab end_ev_lab num2cell(tr_info)];

if isfield(cfg.trial,'start_label')
    trial_ids                 = cell(size(tr_interval,1),1);
    trial_ids(int_start == 1) = cfg.trial.start_label(sort_start_ids);
    trial_ids(int_start == 0) = trial_ids(find(int_start == 0) -1);
    cell_base                 = [trial_ids cell_base];

    trial_fields = {'type','int_label','start_ev','end_ev','num','t_start','t_end','duration'};
else
    trial_fields = {'int_label','start_ev','end_ev','num','t_start','t_end','duration'};
end

trial_struct.trials = cell2struct(cell_base,trial_fields,2);