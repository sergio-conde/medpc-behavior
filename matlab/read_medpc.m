function medpc_data = read_medpc(file_path)

% medpc_data = read_medpc(file_path)
%
% read_medpc function extracts the information contained in medPC output
% files. It looks for every output-block (defined by capital letters 
% e.g., A:, E:, T:, etc.) and store the data in separate fields of the 
% output structure.   
%
% Inputs:
%   file_path: full path including medPC file name                          [char]
%
% Outputs:
%   medpd_data: struct containing the following fields                      [char]
%       header: with all the information before the first block output.     [char]
%       file: File name in header                                           [char]
%       start_date: Start Date in header                                    [char]
%       end_date: End Date in header                                        [char]
%       subject: Subject in header                                          [char]
%       experiment: Experiment in header                                    [char]
%       group: Group in header                                              [char]
%       box: Box in header                                                  [char]
%       start_time: Start Time in header                                    [char]
%       end_time: End Time in header                                        [char]
%       msn: MSN in header                                                  [char]
%       dur_min: session duration in minutes                                [double]
%       (block_name): multiple fields named after each block (e.g., E, T,   [double]
%                     etc.), and containig the data in vectors.
%
% Sergio Conde, Jun 2024. NIN. Willuhn's Lab.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_data = fileread(file_path);                                            % read medPC file

% reads the block's labels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
block_names = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';                                 % default block order
block_start = zeros(1,length(block_names));                                 % default block indexing
for iblock = 1:length(block_names)
    block_flag = strfind(file_data,[block_names(iblock) ':']);              % look for the index of the each block label
    if ~isempty(block_flag)                                                 % if the block exists
        block_start(iblock) = block_flag(end);                              % strore block indexing
    end
end
[ind, order]    = sort(block_start);                                        % order blocks based on their index
block_names     = block_names(order);                                       % reorder block labels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


medpc_data.header = file_data(1:ind(1) - 1);                                % store header (everything before the first block label)

% finds header's labels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
st_date_id  = strfind(medpc_data.header,'Start Date:');
end_date_id = strfind(medpc_data.header,'End Date:');
subject_id  = strfind(medpc_data.header,'Subject:');
exp_id      = strfind(medpc_data.header,'Experiment:');
group_id    = strfind(medpc_data.header,'Group:');
box_id      = strfind(medpc_data.header,'Box:');
st_time_id  = strfind(medpc_data.header,'Start Time:');
end_time_id = strfind(medpc_data.header,'End Time:');
msn_id      = strfind(medpc_data.header,'MSN:');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% splits and stores header's data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
medpc_data.file       = medpc_data.header(7:st_date_id - 3);
medpc_data.start_date = medpc_data.header(st_date_id + 12:end_date_id - 3);
medpc_data.end_date   = medpc_data.header(end_date_id + 10:subject_id - 3);
medpc_data.subject    = medpc_data.header(subject_id + 9:exp_id - 3);
medpc_data.experiment = medpc_data.header(exp_id + 12:group_id - 3);
medpc_data.group      = medpc_data.header(group_id + 7:box_id - 3);
medpc_data.box        = medpc_data.header(box_id + 5:st_time_id - 3);
medpc_data.start_time = medpc_data.header(st_time_id + 12:end_time_id - 3);
medpc_data.end_time   = medpc_data.header(end_time_id + 10:msn_id - 3);
medpc_data.msn        = medpc_data.header(msn_id + 5:end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% computes session duration in minutes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_t             = duration(medpc_data.start_time);
end_t               = duration(medpc_data.end_time);
medpc_data.dur_min  = minutes(end_t - start_t);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reads the data from each block %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ind = [ind length(file_data)];                                              % this allows to pick the data up to the end of the file
for iblock = 1:length(block_names)
    if ind(iblock) > 0                                                      % if the block exists
        block_txt   = file_data(ind(iblock):ind(iblock + 1));               % take data between the current block and the following one
        def_line    = [strfind(block_txt,':') length(block_txt)];           % find ':' indexes to define block lines
        cat_events  = [];                                                   % initialize variable
        for idef = 1:length(def_line) - 1
            loc_line  = block_txt(def_line(idef) : def_line(idef + 1));     % blocl line selection
            end_num   = strfind(loc_line,'.') + 3;                          % find number's end
            if ~isempty(end_num)
                loc_line    = loc_line(1:max(end_num));
                space_flags = strfind(loc_line,' ');                        % find empty spaces to define individual numbers
                start_num   = space_flags(diff(space_flags) > 1) + 1;       % find the start of each number
                if max(space_flags) < length(loc_line)                      % in case there is only one number (e.g., first block in the list)
                    start_num = cat(2,start_num,max(space_flags));
                end
                for inum = 1:length(start_num)
                    loc_num     = loc_line(start_num(inum):end_num(inum));  % cut text number
                    cat_events  = cat(2,cat_events,str2double(loc_num));    % transform to double
                end
            end
        end
        medpc_data.(block_names(iblock)) = cat_events;                      % store using the block label as a field name
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
