function varargout = gravity(varargin)
% GRAVITY MATLAB code for gravity.fig
%      GRAVITY, by itself, creates a new GRAVITY or raises the existing
%      singleton*.
%
%      H = GRAVITY returns the handle to a new GRAVITY or the handle to
%      the existing singleton*.
%
%      GRAVITY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRAVITY.M with the given input arguments.
%
%      GRAVITY('Property','Value',...) creates a new GRAVITY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gravity_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gravity_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gravity

% Last Modified by GUIDE v2.5 25-Sep-2014 14:21:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gravity_OpeningFcn, ...
                   'gui_OutputFcn',  @gravity_OutputFcn, ...
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

% --- Executes just before gravity is made visible.
function gravity_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gravity (see VARARGIN)

% Choose default command line output for gravity
handles.output = hObject;

dev = sensorgroup('AppleMobile');

global SURF HCONTOUR;

var=500;
intensity = rand(8,1);
xmax=350;
ymax = 180;

z=zeros(xmax,ymax);
medx=[331,304,173,43,19,43,173,304];
medy=[90,146,163,146,90,33,17,33];

x_sample=0;
for x=1:xmax
    x_sample=x_sample+1;
    y_sample=0;
    for y=1:ymax
        y_sample=y_sample+1;
        z(x_sample,y_sample)=0;
        for index=1:length(medx);
            z(x_sample,y_sample)=z(x_sample,y_sample)+...
                -intensity(index)*...
                exp((-(x-medx(index))^2-(y-medy(index))^2)/var);
        end
    end
end

SURF = surf(z);
hold on;
[~, HCONTOUR] = contour(z);
set(SURF, 'Visible', 'off');
set(HCONTOUR, 'Visible', 'off');
set(handles.axes, 'Visible', 'off');
        
axes_dev = {handles.axes, dev};

movables = {handles.lbl_1, handles.lbl_2, handles.lbl_3, handles.lbl_4, handles.lbl_5, handles.lbl_6, handles.lbl_7, handles.lbl_8};
for i = 1:length(movables)
    cur_target = movables{i};
    uistack(cur_target, 'top'); 
    uistack(cur_target, 'down', i-1);
end

% shows how you can attach callback using function handle.
% http://www.mathworks.com/help/techdoc/creating_plots/f7-55506.html
set(hObject, 'WindowButtonMotionFcn', {@target, movables});

set(hObject, 'KeyPressFcn', {@keyPress, axes_dev});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gravity wait for user response (see UIRESUME)
% uiwait(handles.fig_gravity);


% --- Outputs from this function are returned to the command line.
function varargout = gravity_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
