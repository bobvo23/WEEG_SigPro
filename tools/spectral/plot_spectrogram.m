function plot_spectrogram(data, startgr, chan, axes_handles)
%% This function allow us to plot the spectrogram
%
%IN:
%   data:           input data
%   startgr:        the start point of the data
%   chan:           channel (default 1)
%   axes_handles:   plot in figure
%OUT:
%   figure plot the spectrogram of the channal of the data
%
%Exmaple: 
%   % Plot data 'a' started from sample 510
%   plot_spectrogram(a,510)
    

if nargin <3
    chan=1;
    axes_handles = axes;
elseif nargin <4
    axes_handles = axes;
end

% Select channel to plot
data=data(chan,:);

% Segment data to plot
startgraph = startgr;
segmentLength = round(numel(data(startgraph:end))/4.5); % Equivalent to setting segmentLength = [] in the next line

% Spectrogram
spectrogram(double(data(startgraph:end)),round(segmentLength/6),round(80/100*segmentLength/6),[],250,'yaxis');
ylim([5 35]);


    
    