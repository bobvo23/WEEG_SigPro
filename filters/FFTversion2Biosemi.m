%cheng algorithm
figure;
datatestvalue = data1ftft;
datatestvalue2 = data2ftft;
%datatestvalue = dataf lick;
indexdatasaved = 1;
jump = 50;
for i=(1):((length(data1)/jump-11))
%figure;
t1=i*jump;
datatest = datatestvalue(t1:(t1+511));
datatest2 = datatestvalue2(t1:(t1+511));
%datatest = data2(1:end);

Fs = 256; % Sampling frequency
T = 1/Fs; % Sample time
L = length(datatest); % Length of signal
t = (0:L-1)*T; % Time vector
%Multiply NFFT by 2 to get 1024 FFT datapoint, 512 point is from the data,
%zeropadded the rest
NFFT = 2^nextpow2(L*2); % Next power of 2 from length of y
%y1
Y = fft(datatest,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
y=2*abs(Y(1:NFFT/2+1));
% Plot single-sided amplitude spectrum.

y=2*abs(Y(1:NFFT/2+1));
%y=smooth(y);
%y2
Y2 = fft(datatest2,NFFT)/L;
f2 = Fs/2*linspace(0,1,NFFT/2+1);
% Plot single-sided amplitude spectrum.

y2=2*abs(Y2(1:NFFT/2+1));



%Ploting
idx = find(f>=0 & f<=30);
    interestY = y(idx); %f value from 5 to 40Hz
    interestF = f(idx);
    %y2 
    interestY2 = y2(idx); %f value from 5 to 40Hz
    interestF2 = f2(idx);

   subplot(2,1,1);
plot(interestF,interestY,'-x');
title('FFT of Channel 1 - Single-Sided Amplitude Spectrum of y(t) ')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')


 

% Detect peak
%
% indexmax = find(max(interestY) == interestY); %find index of peak y
% xmax = interestF(indexmax);
% ymax = interestY(indexmax);

[sorted,I] = sort(interestY,'descend');    %sort ouput Y
[r,c] = ind2sub(size(interestY),I(1:5));  %//Change 10 to any other required value

xmax = interestF(c(1));
ymax = interestY(c(1));
%y2
indexmax2 = find(max(interestY2) == interestY2); %find index of peak y
xmax2 = interestF2(indexmax2);
ymax2 = interestY2(indexmax2);
     %annotate

[sorted2,I2] = sort(interestY2,'descend');    %sort ouput Y
[r2,c2] = ind2sub(size(interestY2),I2(1:5));  %//Change 10 to any other required value

%%SNR
meanY = mean(interestY);
% snr = ymax/meanY;
% 
% %snr = 20 * log10((ymax/meanY)^2);
% strmax = ['Max= ',num2str(xmax),' SNR= ',num2str(snr)];
% %strmax = ['Max= ',num2str(xmax)];

textcolor='rbkymg';
%change color based on algo decision

   
%text(xmax,ymax,strmax,'HorizontalAlignment','left','color',textcolor(tc));  
for k=1:3
    %snr = 20 * log10((ymax/meanY)^2);
    strmax = ['Max= ',num2str(interestF(c(k))),' SNR= ',num2str(interestY(c(k))/meanY)];
    %strmax = ['Max= ',num2str(xmax)];
    if (interestY(c(k))/meanY > 3.2) 
      tc = 1; %assign red if it is a detection  
    else
      tc = 2;
    end
    text(interestF(c(k)),interestY(c(k)),strmax,'HorizontalAlignment','left','color',textcolor(tc)); 
end

%% Y2

subplot(2,1,2);
plot(interestF2,interestY2);
title('FFT of Channel 2 - Single-Sided Amplitude Spectrum of y(t) ')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

%xlim([5 40]);
%%SNR
meanY2 = mean(interestY2);
% snr2 = ymax2/meanY2;
% 
% %snr = 20 * log10((ymax/meanY)^2);
% strmax2 = ['Max= ',num2str(xmax2),' SNR= ',num2str(snr2)];
% %strmax = ['Max= ',num2str(xmax)];
% 
% textcolor='rbkymg';
% %change color based on algo decision
% if (snr2 > 3.2) 
%   tc2 = 1; %assign red if it is a detection  
% else
%   tc2 = 2;
% end
%     
% text(xmax2,ymax2,strmax2,'HorizontalAlignment','left','color',textcolor(tc2));  
for k2=1:3
    %snr = 20 * log10((ymax/meanY)^2);
    strmax2 = ['Max= ',num2str(interestF2(c2(k2))),' SNR= ',num2str(interestY2(c2(k2))/meanY2)];
    %strmax = ['Max= ',num2str(xmax)];
    if (interestY2(c2(k2))/meanY2 > 3.2) 
      tc2 = 1; %assign red if it is a detection  
    else
      tc2 = 2;
    end
    text(interestF2(c2(k2)),interestY2(c2(k2)),strmax2,'HorizontalAlignment','left','color',textcolor(tc2)); 
end
%%
pause(0.1);
display(t1);


% computeddata(1,indexdatasaved) = xmax;
% computeddata(2,indexdatasaved) = ymax;
% computeddata(3,indexdatasaved) = snr;

spectro{indexdatasaved}={f2,y2,t1,c2};

indexdatasaved = indexdatasaved+1;
end

% target 1
figure;
%6.6: 28; 7.5:32; 8.7:37; 10:42
targetf = [51, 62, 63, 73];
for target = 1:4
indexf = targetf(target) ;
for i=1:(indexdatasaved-1)
localsnrvalue = 0;
k=spectro{i}(1,2)
tdraw = spectro{i}(1,3);
xdrawm(i) = tdraw{1}(1);
ydrawm(i) = k{1}(indexf);
eachsidevalues = 2;
    for j = (-eachsidevalues):eachsidevalues
    localsnrvalue = localsnrvalue + k{1}(indexf+j);
    end
    %compare the value to 5 nearby value
    localsnr(i) = k{1}(indexf) * eachsidevalues*2 /(localsnrvalue-k{1}(indexf)); %dont' count target value
end

subplot(4,2,(target*2-1))
plot(xdrawm,ydrawm,'-x');
ylim([0 3*10^(-6)]);
title('Amplitude over time')
%f = 10-164
subplot(4,2,target*2);
plot(xdrawm,localsnr);
ylim([0 4.5]);
end

% target2
figure;
for i =1:(indexdatasaved-1)
topvalue = spectro{i}(1,4);
matrixtop(i,:) = topvalue{1};
end
%f = Fs/2*linspace(0,1,NFFT/2+1);
xaxis = linspace(0,1,length(matrixtop(:,1)));
plot(xaxis,matrixtop(:,1),'x');
hold on
plot(xaxis,matrixtop(:,2),'x');
plot(xaxis,matrixtop(:,3),'x');
plot(xaxis,matrixtop(:,4),'x');
plot(xaxis,matrixtop(:,5),'x');