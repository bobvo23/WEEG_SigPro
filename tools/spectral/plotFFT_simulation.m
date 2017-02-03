function plotFFT_simulation(sig, Fs, chan, windowL, overlap, ha_fft, event, ha_event)
%% PLOTFFT_SIMULATION visualizes simulated power spectrum in realtime. The 
% peak of each power spectrum at given time is detected and marked. The
% corresponding SNR value is also calculated.
% 
% In:
%   Sig     : the signal that needs analyzing
%   Fs      : sampling frequency
%   chan    : channel, default: 1
%   windowL : window length, default: 510
%   overlap : overlapping portion of the moving window, from 0 to 1, default:1
%
% Example:
%   % Given sig is the EEG signal collected in Oz channel with sampling frequency is equal 250
%   clearvars;
%   load('data1ftft.mat');      % this will release 'data1ftft1' variable
%   plotFFT_simulation(data1ftft, 255);
%
% See also fft
global i
global iend ts
 %queue for snr to make sure that high snr is a high snr from brainwaves 
% rather than noises
persistent snrqueue;
snrqueue = zeros(1,4);

if nargin < 3
    chan=1;
    windowL = 510;
    overlap = 1;
    ha_fft=subplot(1,1,1);
    
elseif nargin < 4
    windowL=510;
    overlap = 1;
    ha_fft=subplot(1,1,1);
    
elseif nargin < 5
    overlap = 1;
    ha_fft=subplot(1,1,1);
    
end
    
numberchan=size(sig(:,1));  %selec channel
if chan > numberchan
    error(message('The signal does not include that channel',chan));
end
data=sig(chan,:);



% Initializing
L = length(data);        % Length of the signal
T = 1/Fs;               % Sample time
ts = (0:L-1)*T;          % Time vector


% Set up parameters for Fourier transform
% Double number of FFT point by two time window Length, peak finding
% technique
NFFT = 2^nextpow2(windowL*2);           % Next power of 2 from length of y, required for fast fourier transform to perform at its best
f = Fs/2*linspace(0,1,NFFT/2+1);% frequency series vector

% Initialize the plot
%figure('Name', 'Simulated Realtime FFT analyzing')
hplot = plot(ha_fft,f, f);             % Plot anything, doesnt matter
htext = text(0,0, 'Nothing', 'HorizontalAlignment', 'left','Parent',ha_fft);   % Init a text for peak
htitle = title(ha_fft,'Simulated Real Time Power Spectrum');
xlabel(ha_fft,'Frequency (Hz)'); ylabel(ha_fft,'|Y(f)|');

% Event marker plot
% timemarker = time_simulation(event, ha_event, Fs);

% Start stimulation
jump = floor(overlap*windowL);

if isempty(i)
   i = 1;
end

if isempty(iend)
    iend=L-windowL;
end
    

for i=i:jump:iend
    x = data(i:(i+windowL));             % Fraction of signal being analyzed
    y_temp = fft(x,NFFT)/windowL;       % Perform Fourier Transform
    y = 2*abs(y_temp(1:NFFT/2+1));      % Take absolute values and only the first half of the result since the second is just a mirror of the first one.

    % Segment the interested range of frequency (from 5 to 40Hz)
    idx = find(f>=5 & f<=40);
    interestY = y(idx); 
    interestF = f(idx);
    
    % Update plot's data
    set(hplot, 'XData', interestF);
    set(hplot, 'YData', interestY);
    
    % Detect peak  
    indexmax = find(max(interestY) == interestY); % Find index of peak y
    xmax = interestF(indexmax);
    ymax = interestY(indexmax);

    % SNR
    meanY = mean(interestY);
   
    snrqueue =[snrqueue(2:end) ymax/meanY]; %shift new snr data to queue
    
    strmax = ['Max= ',num2str(xmax),' SNR= ',num2str(snrqueue(end))];
    textcolor='rbkymg';
   
    % Change color based on algo decision
    if (snrqueue > 5) 
      tc = 1; %assign red if it is a detection  
    else
      tc = 2;
    end
    
    % Update text
    set(htext, 'Position', [xmax ymax], 'String', strmax, 'color', textcolor(tc));
    
    % Update title
    set(htitle, 'string', sprintf('Simulated Real Time Power Spectrum at t = %.2f', ts(i)));
    
    % Update time marker
%     set(timemarker, 'XData', [i i]/Fs);
    
    if i == 1
        continue;
    else
        pause(ts(i) - ts(i-jump));
    end

end
  

