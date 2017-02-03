function varargout = Offline_SpectralAnalysis(varargin)
%% This guide will plot eeg signal that have multip channel
%
%Number of channel will show number of channel that the data has
%
%The channel in the panel FFT is the channel that you want to plot,  
%   default:1
%



gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Offline_SpectralAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @Offline_SpectralAnalysis_OutputFcn, ...
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


% --- Executes just before Offline_SpectralAnalysis is made visible.
function Offline_SpectralAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Offline_SpectralAnalysis (see VARARGIN)

% Choose default command line output for Offline_SpectralAnalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Offline_SpectralAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Offline_SpectralAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in push_run.
function push_run_Callback(hObject, eventdata, handles)
% hObject    handle to push_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global data event 


text_push=get(handles.push_run,'String');

if strcmp(text_push, 'Run')
    cla (handles.axes_simulation,'reset');
    cla (handles.axes_event,'reset');
    
    set(handles.push_run,'String','Pause');
    
    
    
    i=1;                                            %setup plot start at i=1
                          %setup plot end at i=L-windowL

    %setup for slider    
    
          
    set(handles.slider_simulation,'SliderStep', [windowL/iend 10*windowL/iend]);
    max=get(handles.slider_simulation,'Max'); 
    
    plotFFT_simulation(data, Fs, chan, windowL, overlap, ...
                        handles.axes_simulation, event, handles.axes_event);
    
               
elseif strcmp(text_push,'Pause')
    set(handles.push_run,'String','Run');
    uiwait(GUI_eeg);

end


% --- Executes on button press in push_bf.
function push_bf_Callback(hObject, eventdata, handles)
% hObject    handle to push_bf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data event iend windowL Fs chan overlap jump

[filename pathname] = uigetfile({'*.mat'},'File Selector');
fullfiledata= strcat(pathname, filename);
loadvar = load(fullfiledata, 'ALLEEG');
set(handles.loadfile_edit,'String',fullfiledata);

data = loadvar.ALLEEG.data;
event = loadvar.ALLEEG.event;
numberchan=size(data(:,1),1);                              %set show the channel that the data has
set(handles.numberofchan_text,'String',numberchan);

Fs=get(handles.fft_edit_fs,'String');           %set fs
Fs=str2num(Fs);

chan=get(handles.fft_edit_chan,'String');       %set channel
chan=str2num(chan);

windowL=get(handles.fft_edit_wl,'String');      %set window length
windowL=str2num(windowL);

overlap=get(handles.fft_edit_ol,'String');      %set overlap
overlap=str2num(overlap);

jump=floor(overlap*windowL);

iend=length(data)-windowL;
set(handles.slider_simulation,'Max',iend);
set(handles.slider_simulation,'SliderStep', [0.1*windowL/iend windowL/iend]);


% --- Executes on button press in spectrogram_push_plot.
function spectrogram_push_plot_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogram_push_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data

startgr=get(handles.spectrogram_edit_startgr,'String');     %set startgraph
startgr=str2num(startgr);

chan=get(handles.spectrogram_edit_chan,'String');           %set channel
chan=str2num(chan);

plot_spectrogram(data,startgr,chan,handles.axes_spectrogram);


% --- Executes on slider movement.
function slider_simulation_Callback(hObject, eventdata, handles)
% hObject    handle to slider_simulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global data event windowL Fs chan overlap jump ts iend
global i

cla (handles.axes_simulation,'reset');
cla (handles.axes_event,'reset');

i=floor(get(handles.slider_simulation,'Value'));


iend=i+jump;
plotFFT_simulation(data, Fs, chan, windowL, overlap, ...
                        handles.axes_simulation, event, handles.axes_event);

t=ts(i);
% set(handles.t_text,'String', t)



% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_simulation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_simulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in spectrogram_listbox_channel.
function spectrogram_listbox_channel_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogram_listbox_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns spectrogram_listbox_channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spectrogram_listbox_channel


% --- Executes during object creation, after setting all properties.
function spectrogram_listbox_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectrogram_listbox_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spectrogram_edit_startgr_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogram_edit_startgr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spectrogram_edit_startgr as text
%        str2double(get(hObject,'String')) returns contents of spectrogram_edit_startgr as a double


% --- Executes during object creation, after setting all properties.
function spectrogram_edit_startgr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectrogram_edit_startgr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fft_edit_wl_Callback(hObject, eventdata, handles)
% hObject    handle to fft_edit_wl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of fft_edit_wl as text
%        str2double(get(hObject,'String')) returns contents of fft_edit_wl as a double


% --- Executes during object creation, after setting all properties.
function fft_edit_wl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fft_edit_wl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fft_edit_ol_Callback(hObject, eventdata, handles)
% hObject    handle to fft_edit_ol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of fft_edit_ol as text
%        str2double(get(hObject,'String')) returns contents of fft_edit_ol as a double


% --- Executes during object creation, after setting all properties.
function fft_edit_ol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fft_edit_ol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fft_edit_hpf_Callback(hObject, eventdata, handles)
% hObject    handle to fft_edit_hpf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fft_edit_hpf as text
%        str2double(get(hObject,'String')) returns contents of fft_edit_hpf as a double


% --- Executes during object creation, after setting all properties.
function fft_edit_hpf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fft_edit_hpf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fft_edit_lpf_Callback(hObject, eventdata, handles)
% hObject    handle to fft_edit_lpf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fft_edit_lpf as text
%        str2double(get(hObject,'String')) returns contents of fft_edit_lpf as a double


% --- Executes during object creation, after setting all properties.
function fft_edit_lpf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fft_edit_lpf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spectrogram_edit_chan_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogram_edit_chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spectrogram_edit_chan as text
%        str2double(get(hObject,'String')) returns contents of spectrogram_edit_chan as a double


% --- Executes during object creation, after setting all properties.
function spectrogram_edit_chan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectrogram_edit_chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fft_edit_fs_Callback(hObject, eventdata, handles)
% hObject    handle to fft_edit_fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fft_edit_fs as text
%        str2double(get(hObject,'String')) returns contents of fft_edit_fs as a double


% --- Executes during object creation, after setting all properties.
function fft_edit_fs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fft_edit_fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function loadfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Hints: get(hObject,'String') returns contents of loadfile_edit as text
%        str2double(get(hObject,'String')) returns contents of loadfile_edit as a double


% --- Executes during object creation, after setting all properties.
function loadfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function loaddata_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loaddata_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fft_edit_chan_Callback(hObject, eventdata, handles)
% hObject    handle to fft_edit_chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fft_edit_chan as text
%        str2double(get(hObject,'String')) returns contents of fft_edit_chan as a double


% --- Executes during object creation, after setting all properties.
function fft_edit_chan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fft_edit_chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function numberofchan_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberofchan_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called





