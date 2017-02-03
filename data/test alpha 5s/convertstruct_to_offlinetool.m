ALLEEG.data = data2ftft;
%ALLEEG.event = MarkerStruct;
ALLEEG.srate = 250;
for i=1:length(MarkerStruct)
    ALLEEG.event(i).latency = MarkerStruct(i).Latency;
    ALLEEG.event(i).type = MarkerStruct(i).Note;
end


