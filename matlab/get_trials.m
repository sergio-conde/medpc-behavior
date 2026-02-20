
function trial_struct = get_trials(cfg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trial_struct = get_trials(cfg)
%
% get_trials function extracts the trials contained in med_pc files 
% following the user's configuration 
%
% Inputs:
% cfg: configuration struct containing the following fields                 [struct]
%   med_file: MedPC output file. It can be a string with the full path
%   of the file, or the output of the read_medpc function.
% 
%   events: struct with fields named after each event and contining the
%   number used to configure each event in the MedPC
%   start_label: label of the events used to mark the start of the trial
%   start: name of the events in the events field used to mark the start of 
%   the trial
%   end: name of the events used to mark the end of the trial
% 
% Outputs:
%   This struct contains the following fields:
%   * type: trial type, which is defined by the strat_label field of the trial 
%     configuration. 
%   * num: trial number
%   * t_start: start time in seconds
%   * t_end: end time in seconds
%   * duration: in seconds
%   * int_label: interval label. This could be either _trial_ or _iti_% 
%
% Sergio Conde-Ocazionez, Aug 2024. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------- check the med_file input ----------------------------%
if ischar(cfg.med_file)
    med_data = read_medpc(cfg.med_file);
elseif isstruct(cfg.med_file)
    % include here something to check if the struct has the right configuration
    med_data = cfg.med_file;
end

% include defaults for different med_pc configurations, like sample rate

% the medpc output files have the D block which contains the sample number
% of the ocurrence of each event. This way, the actual time would be sample
% * 10e-3

ev_list = fieldnames(cfg.events);
id_list = [];
for iev = 1:length(ev_list)
    id_list = cat(2,id_list,cfg.events.(ev_list{iev}));
end

if ~iscell(cfg.trial.start)
    cfg.trial.start = ev_list(ismember(id_list,cfg.trial.start));
end

if ~iscell(cfg.trial.end)
    cfg.trial.end = cfg.trial.start;
    no_end_flag = 1;
else
    if ~iscell(cfg.trial.end)
        cfg.trial.end = ev_list(ismember(id_list,cfg.trial.end));
    end
    no_end_flag = 0;
end

trial_struct.cfg      = cfg;
trial_struct.med_data = med_data;

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

if no_end_flag
    tr_iti_times = [start_times end_times(2:end)] * 10e-3;
else
    tr_iti_times = [start_times end_times] * 10e-3;
end

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

if isfield(cfg.trial,'label')
    trial_ids                 = cell(size(tr_interval,1),1);
    trial_ids(int_start == 1) = cfg.trial.label(sort_start_ids);
    trial_ids(int_start == 0) = trial_ids(find(int_start == 0) -1);
    cell_base                 = [trial_ids cell_base];

    trial_fields = {'type','int_label','start_ev','end_ev','num','t_start','t_end','duration'};
else
    trial_fields = {'int_label','start_ev','end_ev','num','t_start','t_end','duration'};
end

trial_struct.trials = cell2struct(cell_base,trial_fields,2);

