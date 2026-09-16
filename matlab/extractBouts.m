function boutList = extractBouts(eventTimes, minInterval, varargin)

if length(varargin) > 1
    errorMsg = sprintf('\n--> Too many inputs <--\n');
    error(errorMsg)
end

diffTime    = [minInterval + 1 diff(eventTimes)] > minInterval;
boutStart   = eventTimes(diffTime);
boutEnd     = eventTimes([diffTime(2:end) true]);
duration    = boutEnd - boutStart;
triggCount  = diff(find([diffTime true]));

boutList = table(boutStart',boutEnd',duration',triggCount',...
    'VariableNames',{'boutStart','boutEnd','duration','triggCount'});

if nargin == 3
    minDuration = varargin{1};
    shortBouts = boutList.duration < minDuration;
    boutList(shortBouts,:) = [];
end
