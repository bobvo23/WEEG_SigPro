function varargout = WEEG_SigPro(varargin)
% WEEG_SigPro M-file for WEEG_SigPro.fig
%      WEEG_SigPro, by itself, creates a new WEEG_SigPro or raises the existing
%      singleton*.
%
%      H = WEEG_SigPro returns the handle to a new WEEG_SigPro or the handle to
%      the existing singleton*.
%
%      WEEG_SigPro('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WEEG_SigPro.M with the given input arguments.
%
%      WEEG_SigPro('Property','Value',...) creates a new WEEG_SigPro or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WEEG_SigPro_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WEEG_SigPro_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WEEG_SigPro

% Last Modified by GUIDE v2.5 17-Feb-2017 16:18:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @WEEG_SigPro_OpeningFcn, ...
    'gui_OutputFcn',  @WEEG_SigPro_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before WEEG_SigPro is made visible.
function WEEG_SigPro_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WEEG_SigPro (see VARARGIN)

% Add local folders 
path_filters = './filters';
path_tools = './tools';
fprintf('+++ Add path - filters: %s\n', path_filters);      addpath(path_filters);
fprintf('+++ Add path - offline tools: %s\n', path_tools);  addpath(path_tools);

% Choose default command line output for WEEG_SigPro
handles.output = hObject;
delete(instrfindall);      % Reset Comport

%Initiate global parameter
global dataAll;dataAll = zeros(1, 1e7,'int16'); %pre-allocate a matrix to store session data
global data1; data1 = zeros(1, 1e6,'single');   %pre-allocate a matrix to store data for each channel
global data2; data2 = zeros(1, 1e6,'single');
global data3; data3 = zeros(1, 1e6,'single');
global data4; data4 = zeros(1, 1e6,'single');
global data5; data5 = zeros(1, 1e6,'single');
global data6; data6 = zeros(1, 1e6,'single');
global data7; data7 = zeros(1, 1e6,'single');
global data8; data8 = zeros(1, 1e6,'single');

%Buffer
global linebuffSize; linebuffSize = 1000;   %number of sample in the plot
global t; t=1:linebuffSize;                 % x-axis of the plot
global linebuffer_x
global linebuffer_y
global linebuffer_1;global linebuffer_2;global linebuffer_3;global linebuffer_4;global linebuffer_5;global linebuffer_6;global linebuffer_7;global linebuffer_8;global linebuffer_9;

global h; global h1;global h2;global h3;global h4;global h5;global h6;global h7;global h8;global h9;

linebuffer_x = nan(1,linebuffSize);
linebuffer_y = nan(1,linebuffSize);
%buffer 8 channel
linebuffer_1 = nan(1,linebuffSize);
linebuffer_2 = nan(1,linebuffSize);
linebuffer_3 = nan(1,linebuffSize);
linebuffer_4 = nan(1,linebuffSize);
linebuffer_5 = nan(1,linebuffSize);
linebuffer_6 = nan(1,linebuffSize);
linebuffer_7 = nan(1,linebuffSize);
linebuffer_8 = nan(1,linebuffSize);
linebuffer_9 = nan(1,linebuffSize);
t=1:linebuffSize;                       %x spacing

%
global bufferSize
bufferSize = 5000; % the intterupt of Matlab byteavailable is planed to be 500, here we use 20 times the size of that data as the size of the ringbuffer, unknown optimed size
global packageLength; packageLength =37; % Armbrain 2 header package size (2h+9x3data+4count)
global data; data = nan(bufferSize,1)'; %' for transpose
%global datastream; datastream = nan(bytesToRead,1); %pre allocate for data
global ind
ind = 1;    %buffer index
global variable;
variable =1;
%init data
global last; last = -1;
global first; first = 1;

global dataPointIndex; dataPointIndex = 0;   %index to save data of single channel

set(handles.ListBaudrate,'Value',12); % set default value for serial baud rate
set(handles.ListPortname,'Value',4); % set default value for serial baud rate
set(handles.popupmenuMultiplier,'Value',6); % set default value for serial baud rate

global markerpoint %store marker index value
global markertext;   %store marker note from gui
global markerstruct %store all marker note data
global markerindex
markertext = {};            %init this is a cell array
markerpoint = {};
markerindex = {};


%Filter initialize
global FIRfilter;
global IIRfilter;
FIRfilter = 0;          %Don't use filter until it's tick on the GUI
IIRfilter = 0;
global TCP;
TCP =0;

if TCP == 1
 
% Init tcpip object
handles.tcpipClient = tcpip('10.8.122.147',55000,'NetworkRole','Client');
set(handles.tcpipClient,'InputBufferSize',7688);
set(handles.tcpipClient,'Timeout',5);

% Connect
fopen(handles.tcpipClient);
end
%SerialPort.Baudrate=str2double(getCurrentPopupString(handles.ListBaudrate));
% Update handles structure
guidata(hObject, handles);
save('handles.mat', 'handles');

% UIWAIT makes WEEG_SigPro wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.

function varargout = WEEG_SigPro_OutputFcn(~, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ListPortname.

function ListPortname_Callback(hObject, eventdata, handles)
% hObject    handle to ListPortname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListPortname contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListPortname
% PortNumber=get(handles.ListPortname,'Value');
% Portname=['COM',num2str(PortNumber)];
%set(handles.TextNumber,'String',str);

% --- Executes during object creation, after setting all properties.

function ListPortname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListPortname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ListBaudrate.
function ListBaudrate_Callback(hObject, eventdata, handles)
% hObject    handle to ListBaudrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListFractal_analysisrate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListBaudrate


% --- Executes during object creation, after setting all properties.

function ListBaudrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListBaudrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ListDatabits.

function ListDatabits_Callback(hObject, eventdata, handles)
% hObject    handle to ListDatabits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListDatabits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListDatabits

% --- Executes during object creation, after setting all properties.

function ListDatabits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListDatabits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ListParity.

function ListParity_Callback(hObject, eventdata, handles)
% hObject    handle to ListParity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListParity contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListParity

% --- Executes during object creation, after setting all properties.

function ListParity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListParity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ListStopbits.
function ListStopbits_Callback(hObject, eventdata, handles)
% hObject    handle to ListStopbits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListStopbits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListStopbits


% --- Executes during object creation, after setting all properties.
function ListStopbits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListStopbits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);

% --- Executes on button press in ButtonConnect.
function ButtonConnect_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)Portname =
% getCurrentPopupSjhtring(handles.ListPortname);
% SerialPort=serial(getCurrentPopupString(ListPortname));

%-----------------------Declare global variable-------------------------%
bytesToRead = 500; %500
serialInputBufferSize = 5000; %5000
global plotHandle1; 
global plotHandle2; 
global plotHandle3; 
global plotHandle4;  
global plotHandle5;
global plotHandle6;
global plotHandle7;

%Initiate handle
global single ADSmultiplier;
ADSmultiplier = str2double(getCurrentPopupString(handles.popupmenuMultiplier));
%TCP
global TCP;
hold on;
plotHandle1= plot(handles.axes1,0,'-b','LineWidth',1);
%set(plotHandle1, 'DoubleBuffer', 'on' );
plotHandle2= plot(handles.axes28,0,'-b','LineWidth',1);
plotHandle3= plot(handles.axes25,0,'-b','LineWidth',1);
plotHandle4= plot(handles.axes29,0,'-b','LineWidth',1);
plotHandle5= plot(handles.axesFFT1,0,'-b','LineWidth',1);
plotHandle6= plot(handles.axesFFT2,0,'-b','LineWidth',1);
plotHandle7= plot(handles.axesFFT3,0,'-b','LineWidth',1);
%plotHandle1= plot(t,linebuffer_1);
%axis(handles.axes1,[0 1000 -3 3]);  %set the range for x and y of the axes1 plot
%-----------------------Initiate Serial Port----------------------------%
% Declare variable for serial port
Databits = 8;
Parity = 'None';
Stopbits = 1;
a=get(handles.ButtonConnect,'String');
if strcmp(a,'Connect')
    Portname=getCurrentPopupString(handles.ListPortname);
    SerialPort=serial(Portname);
    SerialPort.Baudrate=str2double(getCurrentPopupString(handles.ListBaudrate));
    SerialPort.Databits=Databits;
    SerialPort.Parity=Parity;
    SerialPort.Stopbits=Stopbits;
    SerialPort.Baudrate=str2double(getCurrentPopupString(handles.ListBaudrate));
    SerialPort.InputBufferSize=serialInputBufferSize;            
    SerialPort.BytesAvailableFcnCount = bytesToRead;
    %SerialPort.BytesAvailableFcnMode = 'terminator';
    SerialPort.BytesAvailableFcnMode = 'byte';
    %Channel=str2double(getCurrentPopupString(handles.ListChan));
    SerialPort.BytesAvailableFcn = {@localReadAndPlot,plotHandle1,bytesToRead};
% Open serial port   
    try
        handles.SerialPort = SerialPort; % s chinh la handles.s
        fopen(handles.SerialPort);
        % hien thi Disconnect
        set(handles.ButtonConnect, 'String','Disconnect')
        %%also open TCP port

        %end tcpip
        drawnow;
    catch e
        if(strcmp(handles.SerialPort.status,'open')==1)
            fclose(handles.SerialPort);
            if TCP == 1
            %close TCP
            % Close port
            fclose(handles.tcpipClient);
            end
        end
        errordlg(e.message); % xu ly loi ngoai le, neu khong co ngoai le xay ra thi se thuc hien catch
    end
%Disconnect serial port 
else
    set(handles.ButtonConnect, 'String','Connect')
    fclose(handles.SerialPort);
end
guidata(hObject, handles); % hObject la cai hien tai

function localReadAndPlot(interfaceObject,~,figureHandle1,bytesToRead)

%% Declare global variables
global dataAll;
global plotHandle1; 
global plotHandle2; 
global plotHandle3; 
global plotHandle4;  
global plotHandle5;
global plotHandle6;
global plotHandle7;
   %rawdata package stream to computer
global datac;    %n%umber of data send: count packets/frames
global data1;   % 24 bit data from channel 1 to 8 raw data extracted from the serial stream 
global data2;   %
global data3;
global data4;
global data5;
global data6;
global data7;
global data8;

global linebuffer_1;global linebuffer_2;global linebuffer_3;global linebuffer_4;global linebuffer_5;global linebuffer_6;global linebuffer_7;global linebuffer_8;global linebuffer_9;



global L;

% declare variables for buffer
global datastream
global last
global first
global bufferSize
global ind
global data
global packageLength
global linebuffSize
global linebuffer_x
global linebuffer_y
global linebuffer_1;global linebuffer_2;global linebuffer_3;global linebuffer_4;global linebuffer_5;global linebuffer_6;global linebuffer_7;global linebuffer_8;global linebuffer_9;
global t;
global h; global h1;global h2;global h3;global h4;global h5;global h6;global h7;global h8;global h9;
global  dataPointIndex;

global ADSmultiplier;
%
load handles;

%% New filter parameter FIR/IIR
    % Parameter for filter
    persistent  wDataCH1 ;persistent  vDataCH1;     % for filter
    persistent lastFFT;
    global  dataplot; global Type; global af, global bf;
    
    global FIRfilter;
    global IIRfilter;
    global TCP;
    %initialize value if FIR filter is on
    if (FIRfilter)
        global h_FIR;
        persistent wDataCH1_FIR, persistent wDataCH2_FIR, persistent wDataCH3_FIR;
        %Init matrix value for the filter at the first run
        if isempty(wDataCH1_FIR)    %only initialize these matrixes on the first run
            wDataCH1_FIR=zeros(1,1e3);
            wDataCH2_FIR=zeros(1,1e3);
            wDataCH3_FIR=zeros(1,1e3);
        end
    end
    
    %initialize value if IIR filter is on
    if (IIRfilter)
        global af_IIR, global bf_IIR;
        persistent wDataCH1_IIR, persistent wDataCH2_IIR, persistent wDataCH3_IIR;
        persistent vDataCH1_IIR, persistent vDataCH2_IIR, persistent vDataCH3_IIR;
        %Init matrix value for the filter at the first run
        if isempty(wDataCH1_IIR)    %only initialize these matrixes on the first run

            wDataCH1_IIR=zeros(1,1e3);   % initialize w and v for channels
            wDataCH2_IIR=zeros(1,1e3);
            wDataCH3_IIR=zeros(1,1e3);
            vDataCH1_IIR=zeros(1,1e3);
            vDataCH2_IIR=zeros(1,1e3);
            vDataCH3_IIR=zeros(1,1e3);

%             wDataCH1_IIR=zeros(1,length(af_IIR));   % initialize w CH1
%             wDataCH2_IIR=zeros(1,length(af_IIR));
%             wDataCH3_IIR=zeros(1,length(af_IIR));
%             vDataCH1_IIR=zeros(1,length(bf_IIR));
%             vDataCH2_IIR=zeros(1,length(bf_IIR));
%             vDataCH3_IIR=zeros(1,length(bf_IIR));

%                 assignin('base','w_init_IIR',wDataCH1_IIR);
%              assignin('base','v_init_IIR',vDataCH1_IIR);
%              assignin('base','af_IIR_init',af_IIR);
%              disp('init IIR');
        end
    end
%% SNR calculation initiation

if ~exist('sumweight')   %initiate value in the 1st run
    persistent lastcommand1; lastcommand1 =0;
    persistent lastcommand2; lastcommand1 =0;
    persistent peakf;
    %harmonic to detect > these are peak value of the interest F with idx =
    %find(f1>=5 & f1<=25); f has512 values
    peakf = [7, 8, 34; 10 , 11, 41; 15, 16, 15; 28 , 29, 30];  %index in the interestF matrix
    peakf = peakf + 21;                                        %offset index in the f matrix - 1024 NFFT
    %weight of different frequency in the harmonic
    persistent weight;
    weight = [1, 1, 1];                                        %same weight for all frequency in the harmonic
    sumweight = 0;
    %Threshold to decide a valid target
    persistent freqthreshold; freqthreshold = 2.2;
    %Index of the ringbuffer sumsnr1 and 2
    persistent idxsumsnr1; idxsumsnr1 = 1; persistent idxsumsnr2; idxsumsnr2 = 1;
    persistent snrsum1; persistent snrsum2;
    snrqueue = 4;                                              % Define how many recent value to keep
    snrsum1 = zeros(length(peakf(:,1)),snrqueue);              % 4x4 matrix to hold recent snrsum value everyrow is a target freq
    snrsum2 = zeros(length(peakf(:,1)),snrqueue);              % this hold last 4 freq snr sum.    
    for iw = 1:length(weight)
        sumweight = sumweight + weight(iw);
    end
    weight = weight/sumweight;
end
%% End of cell


%% Start reading data
    % Read the desired number of data bytes
    datastream = fread(interfaceObject,bytesToRead); % read binary data from serial port

    %put datastream in the buffer
    for indDatastream = 1:bytesToRead %5 is the length of the data stream
    last = mod(ind-1, bufferSize)+1;         %calulate the index to put data in. The mod function help to maintain the ring buffer
    data(last) = datastream (indDatastream); %copy data from datastream buffer to ringbuffer
    dataAll(1,ind) = datastream (indDatastream);
    % A(i,:) = rowVe1ec
    ind = ind +1;                           %index indicate number of bytes were read
    end    
    
    %condition to analyze data
    % (last > packageLength) : make sure there are enough data to analyze
    % also prevent the half data package
    % (last > packageLength) && first > last : full buffer, last cross over
    % the bufferlimit 1 round before the first
    % (last > packageLength) && (last > first+packageLength) : normal
    % condition
    if (last > packageLength) && (( first > last)||(last > first+packageLength)) 
        %% process all data in the ring
        while (     (last > (first + packageLength)) || (first > last)     )    %condition to make sure the available byte in the buffer is more than 1 package
        %look for new header
            
            % range of first: from 1 to bufferSize. That's why we need to
            % -1 in the modular function, then +1 outside to make sure that
            % we got first = bufferSize value after the mod function
            
            if ((data(mod(first-1 +0, bufferSize)+1) == 254) && (data(mod(first-1 + 1, bufferSize)+1) == 1) && (data(mod(first-1 + 2, bufferSize)+1) == 254)&& (data(mod(first-1 + 3, bufferSize)+1) == 1)&& (data(mod(first-1 + 4, bufferSize)+1) == 254)&& (data(mod(first-1 + 5, bufferSize)+1) == 1) )  %fake header
            %frame header detected, start to analyze data of a frame
            %output_x = [output_x ; data(mod(first-1 + 2, bufferSize)+1)] ;       %2 in the index within a frame of xput meaningful data after the header to output matrix check t
            %===============================*************==============================================
            % A data structure sample
            % Byte 1: Header 1 
            % Byte 2: Header 2
            % Byte 3: Status 1
            % Byte 4: Status 2
            % Byte 5: Status 3
            % Byte 6: Channel 1 Byte 1 
            % Byte 7: Channel 1 Byte 2
            % Byte 8: Channel 1 Byte 3
            % Byte 9: Channel 2 Byte 1
            % Byte 10: Channel 2 Byte 2
            % Byte 11: Channel 2 Byte 3
            %
            %
            %
            %
            %
            %
            %
            %
            %
            %
            %
            %
            %
            %
            %
            % Byte 33: Channel 8 Byte 3
            %============================***********===========================================
            
            %plot channel 1: 5 6 7
            %
            %debug
            
            dataPointIndex = dataPointIndex +1;         %index to the next location to save new data
            %disp(dataPointIndex);
            datatmp = data(mod(first-1 + 5 +4, bufferSize)+1)*65536 + data(mod(first-1 + 6+4, bufferSize)+1)*256+data(mod(first-1 + 7 +4, bufferSize)+1);       %combine seperate bytes of channel 1
            datatmp = (datatmp*4.5/(2^23-1)-4.5)/ADSmultiplier;               %Convert to volt
            linebuffer_1 =[linebuffer_1(2:end) datatmp];  %4 is the location of 16 in dataall. location of 254 is 0
            data1(dataPointIndex)= datatmp;
                      
            %plot channel 2: 8 9 10
            datatmp = data(mod(first-1 + 8 +4, bufferSize)+1)*65536 + data(mod(first-1 + 9 +4, bufferSize)+1)*256+data(mod(first-1 + 10+4, bufferSize)+1);       %combine seperate bytes of channel 1
            datatmp = (datatmp*4.5/(2^23-1)-4.5)/ADSmultiplier;
            linebuffer_2 =[linebuffer_2(2:end) datatmp];  %4 is the location of 16 in dataall. location of 254 is 0
            data2(dataPointIndex)= datatmp;
            
            %plot channel 3: 11 12 13   -temperature channel
            datatmp = data(mod(first-1 + 11 +4, bufferSize)+1)*65536 + data(mod(first-1 + 12 +4, bufferSize)+1)*256+data(mod(first-1 + 13 +4, bufferSize)+1);       %combine seperate bytes of channel 1
            datatmp = (datatmp*4.5/(2^23-1)-4.5)/ADSmultiplier;
            linebuffer_3 =[linebuffer_3(2:end) datatmp];  %4 is the location of 16 in dataall. location of 254 is 0
            data3(dataPointIndex)= datatmp;
            
            
            %plot channel 4: 14 15 16
            datatmp = data(mod(first-1 + 14 +4, bufferSize)+1)*65536 + data(mod(first-1 + 15 +4, bufferSize)+1)*256+data(mod(first-1 + 16 + 4, bufferSize)+1);       %combine seperate bytes of channel 1
            datatmp = (datatmp*4.5/(2^23-1)-4.5)/ADSmultiplier;
            linebuffer_4 =[linebuffer_4(2:end) datatmp];  %4 is the location of 16 in dataall. location of 254 is 0
            data4(dataPointIndex) = datatmp;
            
            %plot channel 5: 17 18 19
            datatmp = data(mod(first-1 + 17 +4, bufferSize)+1)*65536 + data(mod(first-1 + 18+4, bufferSize)+1)*256+data(mod(first-1 + 19+4, bufferSize)+1);       %combine seperate bytes of channel 1
            datatmp = (datatmp*4.5/(2^23-1)-4.5)/ADSmultiplier;
            linebuffer_5 =[linebuffer_5(2:end) datatmp];  %4 is the location of 16 in dataall. location of 254 is 0
            data5(dataPointIndex) = datatmp;
            
            
            %plot channel 6: 20 21 22
            datatmp = data(mod(first-1 + 20 +4, bufferSize)+1)*65536 + data(mod(first-1 + 21 +4, bufferSize)+1)*256+data(mod(first-1 + 22+4, bufferSize)+1);       %combine seperate bytes of channel 1
            datatmp = (datatmp*4.5/(2^23-1)-4.5)/ADSmultiplier;
            linebuffer_6 =[linebuffer_6(2:end) datatmp];  %4 is the location of 16 in dataall. location of 254 is 0
            data6(dataPointIndex) = datatmp;
            
            %plot channel 7: 23 24 25
            datatmp = data(mod(first-1 + 23+4, bufferSize)+1)*65536 + data(mod(first-1 + 24+4, bufferSize)+1)*256+data(mod(first-1 + 25+4, bufferSize)+1);       %combine seperate bytes of channel 1
            datatmp = (datatmp*4.5/(2^23-1)-4.5)/ADSmultiplier;
            linebuffer_7 =[linebuffer_7(2:end) datatmp];  %4 is the location of 16 in dataall. location of 254 is 0
            data7(dataPointIndex) = datatmp;
            
            %plot channel 8: 26 27 28
            datatmp = data(mod(first-1 + 26+4, bufferSize)+1)*65536 + data(mod(first-1 + 27+4, bufferSize)+1)*256+data(mod(first-1 + 28+4, bufferSize)+1);       %combine seperate bytes of channel 1
            datatmp = (datatmp*4.5/(2^23-1)-4.5)/ADSmultiplier;
            linebuffer_8 =[linebuffer_8(2:end) datatmp];  %4 is the location of 16 in dataall. location of 254 is 0
            data8(dataPointIndex) = datatmp;
            
            
            %output_y = [output_y ; data(mod(first-1 + 3, bufferSize)+1)] ;
            linebuffer_9 =[linebuffer_9(2:end) data(mod(first-1 + 32+ 4, bufferSize)+1)];  %32 is the location of the last counter
           
            first = mod(first-1 +packageLength, bufferSize)+1;                  %completed reading current package, index to the next pakcage    
            
            else first = mod(first-1 +1, bufferSize)+1 ;
        
            end
%% Filter section: every data of channel 1,2,3
        %Filter FIR for all channels
        if(FIRfilter)
        M0_FIR = length(h_FIR)-1;   %M0 order
        %=======================filter channel 1==================================
        [linebuffer_1(end),wDataCH1_FIR] = FilterRealtimeFIR(linebuffer_1(end),h_FIR,M0_FIR,wDataCH1_FIR);
        [linebuffer_2(end),wDataCH2_FIR] = FilterRealtimeFIR(linebuffer_2(end),h_FIR,M0_FIR,wDataCH2_FIR);
        [linebuffer_3(end),wDataCH3_FIR] = FilterRealtimeFIR(linebuffer_3(end),h_FIR,M0_FIR,wDataCH3_FIR);
        end
        %Filter IIR for all channels
        if(IIRfilter)
        M0_IIR=length(af_IIR)-1;
        L0_IIR=length(bf_IIR)-1;   %M0/L0 Order order
        %=======================filter channel 1==================================
%         assignin('base','vDataCH1_IIR_before',vDataCH1_IIR);
%         assignin('base','vDataCH1_IIR_before',wDataCH1_IIR);
        [linebuffer_1(end),wDataCH1_IIR,vDataCH1_IIR]= FilterRealtimeIIR(M0_IIR,af_IIR,L0_IIR,bf_IIR,wDataCH1_IIR,vDataCH1_IIR,linebuffer_1(end));
        [linebuffer_2(end),wDataCH2_IIR,vDataCH2_IIR]= FilterRealtimeIIR(M0_IIR,af_IIR,L0_IIR,bf_IIR,wDataCH2_IIR,vDataCH2_IIR,linebuffer_2(end));
        [linebuffer_3(end),wDataCH3_IIR,vDataCH3_IIR]= FilterRealtimeIIR(M0_IIR,af_IIR,L0_IIR,bf_IIR,wDataCH3_IIR,vDataCH3_IIR,linebuffer_3(end));
        end
 % End filter section       
 %% FFT calculation
           %% Plot FFT _ SNR and calculation
       %if(mod(dataPointIndex,128) == 0) %calculate FFT every 128 samples
            datatestvalue1 = linebuffer_1((end-510):end);      %take exactly 511 last values
            Fs = 250; % Sampling frequency
            T = 1/Fs; % Sample time
            L = length(datatestvalue1); % Length of signal
            t = (0:L-1)*T; % Time vector
            %Multiply NFFT by 2 to get 1024 FFT datapoint, 512 point is from the data,
            %zeropadded the rest
            NFFT = 2^nextpow2(L*2); % Next power of 2 from length of y
            %y1
            Y1 = fft(datatestvalue1,NFFT)/L;
            f1 = Fs/2*linspace(0,1,NFFT/2+1);
            y1=2*abs(Y1(1:NFFT/2+1));
            % Plot single-sided amplitude spectrum.
            idx = find(f1>=5 & f1<=25);
            interestY1 = y1(idx); %f value from 5 to 40Hz
            interestF1 = f1(idx);
            %% Calculate SNR channel 1
            meanY1 = mean(interestY1);
            for targeti = 1:length(peakf(:,1))           %run through peakf matrix
                    snrsumtmp1 = 0;              %reset for this loop
                    for peakfidx = 1: length(peakf(1,:))
                        snrsumtmp1 = snrsumtmp1 + y1(peakf(targeti,peakfidx)) * weight(peakfidx);     
                    end
                    snrsum1(targeti,idxsumsnr1) = snrsumtmp1/meanY1;       
            end
            %Reset idx for the ring buffer
            if idxsumsnr1 >= 4
                idxsumsnr1 = 1;
            else
                idxsumsnr1 = idxsumsnr1+1;
            end
            % plot channel 1
            %strtitle1 = ['6.6: ',num2str(snrsum1(1,idxsumsnr1)),'7.5: ',num2str(snrsum1(2,idxsumsnr1)),'8.75: ',num2str(snrsum1(3,idxsumsnr1)),'10: ',num2str(snrsum1(4,idxsumsnr1))];
%             subplot(2,1,1);
%             plot(interestF1,interestY1,'-x');

%             for snrsum1ridx = 1 : length(snrsum1(:,1)) %go through all the column 
%                 if snrsum1(snrsum1ridx,:) > freqthreshold
%                     if (snrsum1ridx ~= lastcommand1)
%                     %disp('true');
%                     strtitle1 = ['Target',num2str(snrsum1ridx)];
%                     %Send TCP command
%                     % Send data
%                     %fwrite(handles.tcpipClient, num2str(snrsum1ridx), 'char');
%                     lastcommand1 = snrsum1ridx;
%                     end
%                     break; %quite loop if frequency if found
%                 else
%                     strtitle1 = ['wait_C1'];
%                     lastcommand1 = 0;
%                 end   
%             end
      
               %text(6,0,strtitle1,'HorizontalAlignment','left','Parent',handles.axesFFT1);
%     %        disp(tc);
             
%             title(strtitle1);
%             xlabel('Frequency (Hz)')
%             ylabel('|Y(f)|')


%             [sorted1,I1] = sort(interestY1,'descend');    %sort ouput Y
%             [r1,c1] = ind2sub(size(interestY1),I1(1:5));  %//Change 10 to any other required value
% 
%             xmax1 = interestF1(c1(1));
%             ymax1 = interestY1(c1(1));

       %end %if mode 128
       %% FFT channel 2
              %if(mod(dataPointIndex,128) == 0) %calculate FFT every 128 samples
            datatestvalue2 = linebuffer_2((end-510):end);      %take exactly 511 last values
            Fs = 250; % Sampling frequency
            T = 1/Fs; % Sample time
            L = length(datatestvalue2); % Length of signal
            t = (0:L-1)*T; % Time vector
            %Multiply NFFT by 2 to get 1024 FFT datapoint, 512 point is from the data,
            %zeropadded the rest
            NFFT = 2^nextpow2(L*2); % Next power of 2 from length of y
            %y1
            Y2 = fft(datatestvalue2,NFFT)/L;
            f2 = Fs/2*linspace(0,1,NFFT/2+1);
            y2=2*abs(Y2(1:NFFT/2+1));
            % Plot single-sided amplitude spectrum.
            idx = find(f2>=5 & f2<=25);
            interestY2 = y2(idx); %f value from 5 to 40Hz
            interestF2 = f2(idx);
            %% Calculate SNR channel 1
            meanY2 = mean(interestY2);
            for targeti = 1:length(peakf(:,1))           %run through peakf matrix
                    snrsumtmp2 = 0;              %reset for this loop
                    for peakfidx = 1: length(peakf(1,:))
                        snrsumtmp2 = snrsumtmp2 + y2(peakf(targeti,peakfidx)) * weight(peakfidx);     
                    end
                    snrsum2(targeti,idxsumsnr2) = snrsumtmp2/meanY2;       
            end
            %Reset idx for the ring buffer
            if idxsumsnr2 >= 4
                idxsumsnr2 = 1;
            else
                idxsumsnr2 = idxsumsnr2+1;
            end
            % plot channel 1
            %strtitle1 = ['6.6: ',num2str(snrsum1(1,idxsumsnr1)),'7.5: ',num2str(snrsum1(2,idxsumsnr1)),'8.75: ',num2str(snrsum1(3,idxsumsnr1)),'10: ',num2str(snrsum1(4,idxsumsnr1))];
%             subplot(2,1,1);
%             plot(interestF1,interestY1,'-x');

%             for snrsum2ridx = 1 : length(snrsum2(:,1)) %go through all the column
%                 if snrsum2(snrsum2ridx,:) > freqthreshold
%                     if (snrsum2ridx ~= lastcommand2)    %only update if new command is present
%                     %disp('true');
%                     strtitle2 = ['Target',num2str(snrsum2ridx)];
%                     %Send TCP command
%                     if TCP == 1
%                     % Send data
%                     fwrite(handles.tcpipClient, num2str(snrsum2ridx), 'char');
%                     end
%                     lastcommand2 = snrsum2ridx;
%                     end
%                                                       
%                     break; %quite loop if frequency if found
%                 else
%                     strtitle2 = ['wait_C2'];
%                     lastcommand2 = 0;
%                 end
%             end
               %text(6,0,strtitle1,'HorizontalAlignment','left','Parent',handles.axesFFT1);
%     %        disp(tc);
             
%             title(strtitle1);
%             xlabel('Frequency (Hz)')
%             ylabel('|Y(f)|')


%             [sorted1,I1] = sort(interestY1,'descend');    %sort ouput Y
%             [r1,c1] = ind2sub(size(interestY1),I1(1:5));  %//Change 10 to any other required value
% 
%             xmax1 = interestF1(c1(1));
%             ymax1 = interestY1(c1(1));

       %end %if mode 128
        end %end while loop

%Move plot to this plot to lessen the update rate
           set(plotHandle1,'Ydata',linebuffer_1);
           set(plotHandle2,'Ydata',linebuffer_2);
           set(plotHandle3,'Ydata',linebuffer_3);
           set(plotHandle4,'Ydata',linebuffer_9);
           %Channel 1
           set(plotHandle5,'Xdata',interestF1);
           set(plotHandle5,'Ydata',interestY1);
%            set(handles.textFFT1, 'String', strtitle1, 'ForegroundColor','r');
            %Channel 2
           set(plotHandle6,'Xdata',interestF2);
           set(plotHandle6,'Ydata',interestY2);
%            set(handles.textFFT2, 'String', strtitle2, 'ForegroundColor','r');
            %% Plot FFT_peak
%Plot every second FFT of 3 channels; FFT value of last 512 value (2 seconds)
%     
%     %if(mod(dataPointIndex,128) == 0) %calculate FFT every 128 samplescl
%             %plot FFT
%             datatest = linebuffer_2(1:510);
%             Fs = str2double(getCurrentPopupString(handles.PopSPS)); % Sampling frequency
%             T = 1/Fs; % Sample time
%             L = length(datatest); % Length of signal
%             t = (0:L-1)*T; % Time vector
% 
%             NFFT = 2^nextpow2(L); % Next power of 2 from length of y
%             Y = fft(datatest,NFFT)/L;
%             f = Fs/2*linspace(0,1,NFFT/2+1);
%             % Plot single-sided amplitude spectrum.
%             y=2*abs(Y(1:NFFT/2+1));
%             %y=smooth(y);
% 
%             %Ploting
%             interestY = y(6:82); %f value from 5 to 40Hz
%             interestF = f(6:82);
%             %plotfft
%             set(plotHandle5,'Xdata',interestF);
%             set(plotHandle5,'Ydata',interestY);

%     %         plot(interestF,interestY);
%     %         title('FFT of 25Hz Stimulus - Single-Sided Amplitude Spectrum of y(t) - smoothed')
%     %         xlabel('Frequency (Hz)')
%     %         ylabel('|Y(f)|')
%             %xlim([5 40]);
% 
% 
%             % Detect peak
%             %
%             indexmax = find(max(interestY) == interestY); %find index of peak y
%             xmax = interestF(indexmax);
%             ymax = interestY(indexmax);
% 
%                  %annotate
% 
%             %%SNR
%             meanY = mean(interestY);
%             snr = ymax/meanY;
% 
%             %snr = 20 * log10((ymax/meanY)^2);
%             strmax = ['Max= ',num2str(xmax),' SNR= ',num2str(snr)];
%             textcolor='rbkymg';
%             %change color based on algo decision
%              if (((snr) > 1.06) & ( (xmax) >9 ) & ( (xmax) <11))
%                tc = 1; %assign red if it is a detection  
%                 %beep;
%              else
%               tc = 2;
%              end
%     %        text(xmax,ymax,strmax,'HorizontalAlignment','left','color',textcolor(tc),'Parent',handles.axesFFT1);
%     %        disp(tc);
%             set(handles.textFFT1, 'String', strmax, 'ForegroundColor',textcolor(tc));
%              
%     %end       %end of if FFT no more
% % next channel FFT
% % 
% %  PREFORMATTED
% %  TEXT
% % 
%     %if(mod(dataPointIndex,128) == 32) %calculate FFT every 128 samples
%             %plot FFT
%             datatest = linebuffer_1(1:510);
%             Fs = str2double(getCurrentPopupString(handles.PopSPS)); % Sampling frequency
%             T = 1/Fs; % Sample time
%             L = length(datatest); % Length of signal
%             t = (0:L-1)*T; % Time vector
% 
%             NFFT = 2^nextpow2(L); % Next power of 2 from length of y
%             Y = fft(datatest,NFFT)/L;
%             f = Fs/2*linspace(0,1,NFFT/2+1);
%             % Plot single-sided amplitude spectrum.
%             y=2*abs(Y(1:NFFT/2+1));
%             %y=smooth(y);
% 
%             %Ploting
%             interestY = y(6:82); %f value from 5 to 40Hz
%             interestF = f(6:82);
% %             %plotfft
%             set(plotHandle6,'Xdata',interestF);
%             set(plotHandle6,'Ydata',interestY);
% 
%     %         plot(interestF,interestY);
%     %         title('FFT of 25Hz Stimulus - Single-Sided Amplitude Spectrum of y(t) - smoothed')
%     %         xlabel('Frequency (Hz)')
%     %         ylabel('|Y(f)|')
%             %xlim([5 40]);
% 
% 
%             % Detect peak
%             %
%             indexmax = find(max(interestY) == interestY); %find index of peak y
%             xmax = interestF(indexmax);
%             ymax = interestY(indexmax);
% 
%                  %annotate
% 
%             %%SNR
%             meanY = mean(interestY);
%             snr = ymax/meanY;
% 
%             %snr = 20 * log10((ymax/meanY)^2);
%             strmax = ['Max= ',num2str(xmax),' SNR= ',num2str(snr)];
%             textcolor='rbkymg';
%             %change color based on algo decision
%              if (((snr) > 1.06) & ( (xmax) >9 ) & ( (xmax) <11))
%                tc = 1; %assign red if it is a detection  
%                 %beep;
%              else
%               tc = 2;
%              end
%     %        text(xmax,ymax,strmax,'HorizontalAlignment','left','color',textcolor(tc),'Parent',handles.axesFFT1);
%        %     disp(tc);
%             set(handles.textFFT2, 'String', strmax, 'ForegroundColor',textcolor(tc));
%              
%         %end
%     %frequency update
%     %drawnow;    
    
    end


    % --- Executes on button press in ButttonExit.
function ButttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to ButttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global datac;    %n%umber of data send: count packets/frames
global data1;   % 24 bit data from channel 1 to 8 raw data extracted from the serial stream 
global data2;   %
global data3;
global data4;
global data5;
global data6;
global data7;
global data8;

global  dataPointIndex;

assignin('base','data1',data1(1:dataPointIndex));
assignin('base','data2',data2(1:dataPointIndex));
assignin('base','data3',data3(1:dataPointIndex));
assignin('base','data4',data4(1:dataPointIndex));
assignin('base','data5',data5(1:dataPointIndex));
assignin('base','data6',data6(1:dataPointIndex));
assignin('base','data7',data7(1:dataPointIndex));
assignin('base','data8',data8(1:dataPointIndex));
%% marker ouput
global markertext;
global markerindex;
%global markerstruct %store all marker note data

assignin('base','MarkerText',markertext);
assignin('base','MarkerIndix',markerindex);

stiProtocol = struct('Latency',markerindex,'Note',markertext);
assignin('base','MarkerStruct',stiProtocol);

close all;

%%%%%%%%%%%%%%%% SUPPORT FUNCTION [1]
function str = getCurrentPopupString(hh)
% getCurrentPopupString returns the currently selected string in the popupmenu with handle hh

% could test input here
if ~ishandle(hh) || strcmp(get(hh,'Type'),'popupmenu')
    error('getCurrentPopupString needs a handle to a popupmenu as input')
end

% get the string - do it the readable way
list = get(hh,'String');
val = get(hh,'Value');
if iscell(list)
    str = list{val};
else
    str = list(val,:);
end



%--- Executes on button press in ButtonSave.
function ButtonSave_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% evalin('base','dataall');
load handles;
global dataall;
uisave('dataall.mat','dataall');


% --- Executes on selection change in ListChan.
function ListChan_Callback(hObject, eventdata, handles)
% hObject    handle to ListChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListChan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListChan


% --- Executes during object creation, after setting all properties.
function ListChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PopSPS.
function PopSPS_Callback(hObject, eventdata, handles)
% hObject    handle to PopSPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopSPS contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopSPS


% --- Executes during object creation, after setting all properties.
function PopSPS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopSPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in PopFilType1.
function PopFilType1_Callback(hObject, eventdata, handles)
% hObject    handle to PopFilType1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopFilType1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopFilType1


% --- Executes during object creation, after setting all properties.
function PopFilType1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopFilType1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TextFc1_Callback(hObject, eventdata, handles)
% hObject    handle to TextFc1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TextFc1 as text
%        str2double(get(hObject,'String')) returns contents of TextFc1 as a double


% --- Executes during object creation, after setting all properties.
function TextFc1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextFc1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PopFilType2.
function PopFilType2_Callback(hObject, eventdata, handles)
% hObject    handle to PopFilType2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopFilType2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopFilType2


% --- Executes during object creation, after setting all properties.
function PopFilType2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopFilType2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TextOrder_Callback(hObject, eventdata, handles)
% hObject    handle to TextOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TextOrder as text
%        str2double(get(hObject,'String')) returns contents of TextOrder as a double


% --- Executes during object creation, after setting all properties.
function TextOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TextFc2_Callback(hObject, eventdata, handles)
% hObject    handle to TextFc2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TextFc2 as text
%        str2double(get(hObject,'String')) returns contents of TextFc2 as a double


% --- Executes during object creation, after setting all properties.
function TextFc2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextFc2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in cboxIIRfilter.
function cboxIIRfilter_Callback(hObject, eventdata, handles)
% hObject    handle to cboxIIRfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cboxIIRfilter
global IIRfilter;
global af_IIR, global bf_IIR;

IIRfilter = get(handles.cboxIIRfilter, 'Value'); %update IIR filter status
    if(IIRfilter)           %generate new parameter
        drawnow;
        Order = str2double(get(handles.editIIRorder,'String'));
        fs=str2double(getCurrentPopupString(handles.PopSPS)); 
        fc = str2double(get(handles.editFciir,'String'));
        [bf_IIR,af_IIR]=newbutter(Order,2*fc/fs,'high');
        
        
    end
    
% --- Executes on button press in cboxFIRfilter.
function cboxFIRfilter_Callback(hObject, eventdata, handles)
% hObject    handle to cboxFIRfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cboxFIRfilter
global FIRfilter;       %global value to indicate FIR filter state
global h_FIR;           %FIR rely only on current and previous inputs

FIRfilter = get(handles.cboxFIRfilter, 'Value'); %update IIR filter status
if(FIRfilter)           %generate new parameter
    drawnow;
    Order=str2double(get(handles.editFIRorder,'String'));
    wHam = hamming(Order+1);
    fs=str2double(getCurrentPopupString(handles.PopSPS)); 
    fc = str2double(get(handles.editFcfir,'String'));
    h_FIR  = fir1(Order,2*fc/fs,wHam);          %create FIR lowpass filter based on given values
end

% --- Executes on button press in cboxCustomFilter.
function cboxCustomFilter_Callback(hObject, eventdata, handles)
% hObject    handle to cboxCustomFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cboxCustomFilter


% --- Executes on selection change in popupmenuMultiplier.
function popupmenuMultiplier_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMultiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMultiplier contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMultiplier


% --- Executes during object creation, after setting all properties.
function popupmenuMultiplier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMultiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuMultiplier.
function popupmenu15_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMultiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMultiplier contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMultiplier


% --- Executes during object creation, after setting all properties.
function popupmenu15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMultiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonMarker.
function pushbuttonMarker_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global markertext;
global markerindex;
global  dataPointIndex;
%getCurrentPopupString(handles.popupMark)
markerindex = [markerindex, {dataPointIndex}];
markertext = [markertext, {getCurrentPopupString(handles.popupMark)}];






function editMarker_Callback(hObject, eventdata, handles)
% hObject    handle to editMarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMarker as text
%        str2double(get(hObject,'String')) returns contents of editMarker as a double


% --- Executes during object creation, after setting all properties.
function editMarker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%test


% --- Executes on selection change in popupMark.
function popupMark_Callback(hObject, eventdata, handles)
% hObject    handle to popupMark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupMark contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupMark


% --- Executes during object creation, after setting all properties.
function popupMark_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupMark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFciir_Callback(hObject, eventdata, handles)
% hObject    handle to editFciir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFciir as text
%        str2double(get(hObject,'String')) returns contents of editFciir as a double


% --- Executes during object creation, after setting all properties.
function editFciir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFciir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFcfir_Callback(hObject, eventdata, handles)
% hObject    handle to editFcfir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFcfir as text
%        str2double(get(hObject,'String')) returns contents of editFcfir as a double


% --- Executes during object creation, after setting all properties.
function editFcfir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFcfir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editIIRorder_Callback(hObject, eventdata, handles)
% hObject    handle to editIIRorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIIRorder as text
%        str2double(get(hObject,'String')) returns contents of editIIRorder as a double


% --- Executes during object creation, after setting all properties.
function editIIRorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIIRorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFIRorder_Callback(hObject, eventdata, handles)
% hObject    handle to editFIRorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFIRorder as text
%        str2double(get(hObject,'String')) returns contents of editFIRorder as a double


% --- Executes during object creation, after setting all properties.
function editFIRorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFIRorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_connectTCP.
function button_connectTCP_Callback(hObject, eventdata, handles)
% hObject    handle to button_connectTCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ipAddress = get(handles.edit_ipAddress, 'String');
ipPort = str2double(get(handles.edit_ipPort, 'String'));

% Open serial port   
try
    % Init tcpip object
    handles.tcpipClient = tcpip(ipAddress, ipPort, 'NetworkRole', 'Client');
    set(handles.tcpipClient,'InputBufferSize',7688);
    set(handles.tcpipClient,'Timeout',5);
    
    % Connect
    fopen(handles.tcpipClient);      
%    drawnow;
catch e
    % Close port first
    if(strcmp(handles.tcpipClient.status,'open')==1)
        fclose(handles.tcpipClient);
    end
    errordlg(e.message);
end

% GIve user a sign
set(handles.text_connectTCP, 'String', 'Connected!');
set(handles.text_connectTCP, 'BackgroundColor', [1 1 0.2]);
   
% Update handles structure
guidata(hObject, handles);



function edit_ipAddress_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ipAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ipAddress as text
%        str2double(get(hObject,'String')) returns contents of edit_ipAddress as a double


% --- Executes during object creation, after setting all properties.
function edit_ipAddress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ipAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ipPort_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ipPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ipPort as text
%        str2double(get(hObject,'String')) returns contents of edit_ipPort as a double


% --- Executes during object creation, after setting all properties.
function edit_ipPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ipPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
