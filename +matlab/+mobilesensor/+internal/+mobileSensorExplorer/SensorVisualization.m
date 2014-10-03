
%   Copyright 2013 The MathWorks, Inc.

classdef SensorVisualization < handle
    
    methods
        function obj = SensorVisualization(sensorName, varargin)

            obj.isAxisCreated = false;
            obj.isSensorGroupCreated = false;
            
            % validate input: Must be at least 1 parameter
            if nargin == 0
                error('MATLAB:sensorvisualization:noparams','sensorName is required')
            end
            
            % validate input: sensorName must be a known name
            if nargin >= 1 && ~any(strcmp(sensorName,{'Acceleration','AngularVelocity',...
                                        'MagneticField',...
                                        'LatitudeLongitude', 'Altitude',...
                                        'Speed','Course','Orientation'}))
                error('MATLAB:sensorvisualization:invalidSensor','sensorName must be one of the supported sensors.')
            end
            obj.sensorName = sensorName;
            
            % validate input: if a sensorgroup or device type is specified,
            % it must be a valid sensorgroup object 'AppleMobile' or 'AndroidMobile'
            if nargin >= 2
                deviceTypeOrSG = varargin{1};
                if ischar(deviceTypeOrSG)
                    if ~any(strcmp(deviceTypeOrSG,{'AppleMobile','AndroidMobile'}))
                        error('MATLAB:sensorvisualization:invalidDeviceType','deviceTypeOrSG must be sensorgroup or ''AppleMobile'' or ''AndroidMobile''')
                    end
                    obj.sg = sensorgroup.empty;
                elseif isa(deviceTypeOrSG,'sensorgroup')
                    obj.sg = deviceTypeOrSG;
                else
                    error('MATLAB:sensorvisualization:invalidSensorGroup','deviceTypeOrSG must be sensorgroup or ''AppleMobile'' or ''AndroidMobile''')
                end
            else    
                obj.sg = sensorgroup.empty;
            end
            
            % validate input: if an axes is specified, it must be valid axis
            if nargin >= 3
                obj.a = varargin{2};
                if ~ishghandle(obj.a) || ~strcmp(get(obj.a,'Type'),'axes')
                    error('MATLAB:sensorvisualization:invalidAxes','a must be an axes')
                end
            else
                obj.a = [];
            end
            
            % If we've validated the inputs, and there's no sensorgroup
            % yet, then create it.
            if isempty(obj.sg)
                obj.isSensorGroupCreated = true;
                obj.sg = sensorgroup(deviceTypeOrSG);
            end
            
            % If we've validated the inputs, and there's no axes yet, then
            % create it.
            if isempty(obj.a)
                obj.isAxisCreated = true;
                obj.a = gca;
            end
            
            % Create an update timer
            obj.updateTimer = timer(  'BusyMode','drop',...
                    'ExecutionMode','fixedRate',...
                    'Period',.1,...
                    'StartDelay',0,...
                    'ErrorFcn',@(src,event)handleError(obj,src,event),...
                    'TimerFcn',@(src,event)handleUpdate(obj,src,event));
            start(obj.updateTimer)
        end

        function delete(obj)
            try
                stop(obj.updateTimer);
            catch %#ok<CTCH>
            end
            if obj.isSensorGroupCreated
                try
                    delete(obj.sg);
                catch %#ok<CTCH>
                end
            end
            if obj.isAxisCreated
                try
                    close(get(obj.a,'Parent'))
                catch %#ok<CTCH>
                end
            end
            try
                delete(obj.updateTimer);
            catch %#ok<CTCH>
            end
        end
        
    end

    properties(GetAccess = protected,SetAccess = private)
        sensorName
        sg
        a
        currentXLim
    end

    methods (Access=protected)
        function processDataImpl(obj, data, ts)     
            if isempty(obj.hLines)
                plotParam = cell(1,size(data,2) * 2);
                for iColumn = 1:size(data,2)
                    plotParam{iColumn * 2 - 1} = ts;
                    plotParam{iColumn * 2} = data(:,iColumn);
                end
                obj.hLines = plot(obj.a,plotParam{:});
                title(obj.a,obj.sensorName)
                info = obj.getSensorInfo();                
                ylabel(obj.a,info.unitName);

                if ~matlab.graphics.internal.isGraphicsVersion1()
                    legend(obj.a,info.legendText);
                end
                
                %datetick(obj.a,'x');
                ylim(obj.a,info.YLimit);
                obj.currentXLim = get(obj.a,'XLim');
            else
                for iColumn = 1:size(data,2)
                    set(obj.hLines(iColumn),'XData',ts,'YData',data(:,iColumn));
                end
                
                if ts(end, :) >= obj.currentXLim(2)
                    %datetick(obj.a,'x');
                    obj.currentXLim = get(obj.a,'XLim');
                end
            end
        end

        function handleError(~,~,~)   
            % Ignore errors
        end

        function handleUpdate(obj,~,~)   
            try
                switch obj.sensorName
                    case 'Acceleration'
                        [data, ts] = obj.sg.accellog();
                    case 'AngularVelocity'
                        [data, ts] = obj.sg.angvellog();
                    case 'MagneticField'
                        [data, ts] = obj.sg.magfieldlog();
                    case 'Orientation'
                        [data, ts] = obj.sg.orientlog();
%                         orientation = obj.sg.AngularVelocity - .019; %obj.sg.Orientation;
%                         if isempty(obj.Xm)
%                             obj.Xm = 0;%.55
%                             obj.Ym = 0.55;%0
%                          end
% %                         alfa = -(orientation(1) - 300) + 90
%                         alfa = -orientation(3)*.2*180/pi
%                         
%                         screensize = get(0, 'screensize');
%                         propXPixel = screensize(3)/.36;
%                         propYPixel = screensize(4)/.20;
%                         
%                         Xm1 = cos(alfa*pi/180)*obj.Xm - sin(alfa*pi/180)*obj.Ym;
%                         Ym1 = sin(alfa*pi/180)*obj.Xm + cos(alfa*pi/180)*obj.Ym;
%                         
%                          obj.Xm=Xm1;
%                          obj.Ym=Ym1;
%                         
%                         XPixel = Xm1*propXPixel
%                         YPixel = Ym1*propYPixel
%                         
%                         import java.awt.Robot;
%                         import java.awt.event.*;
%                         robot = Robot;
%                         robot.mouseMove(screensize(3)/2 - XPixel, screensize(4)/2);

%                         orientation = obj.sg.AngularVelocity - .0115; %obj.sg.Orientation;
%                         if isempty(obj.Xm)
%                             obj.Xm = 0;%.55
%                             obj.Ym = 0.55;%0
%                             obj.Zm = 0;
%                          end
% %                         alfa = -(orientation(1) - 300) + 90
%                         alfa = -orientation(1)*.2*180/pi
%                         
%                         screensize = get(0, 'screensize');
%                         propXPixel = screensize(3)/.36;
%                         propYPixel = screensize(4)/.20;
%                         
%                         Ym1 = cos(alfa*pi/180)*obj.Ym - sin(alfa*pi/180)*obj.Zm;
%                         Zm1 = sin(alfa*pi/180)*obj.Ym + cos(alfa*pi/180)*obj.Zm;
%                         
%                         obj.Ym=Ym1;
%                         obj.Zm=Zm1;
%                         
%                         YPixel = Ym1
%                         ZPixel = Zm1*propYPixel
%                         
%                         import java.awt.Robot;
%                         import java.awt.event.*;
%                         robot = Robot;
%                         robot.mouseMove(screensize(3)/2, screensize(4)/2 + ZPixel);

                        angularVelocity = obj.sg.AngularVelocity;% - .0115; %obj.sg.Orientation;
                        if isempty(obj.Xm)
                            obj.Xm = 0;
                            obj.Ym = 0.55;
                            obj.Zm = 0;
                        end
                        
                        alpha = -(angularVelocity(1)-.0133)*.2
                        theta = -(angularVelocity(3)-.0213)*.2 
                        
                        screensize = get(0, 'screensize');
                        propXPixel = screensize(3)/.36;
                        propZPixel = screensize(4)/.20;
                        
                        Rz_th = [cos(theta), -sin(theta), 0; ...
                                 sin(theta), cos(theta),  0; ...
                                 0,          0,           1];
                        
                        Rx_al = [1,          0,           0; ...
                                 0,          cos(alpha),  -sin(alpha); ...
                                 0,          sin(alpha),  cos(alpha)];
                             
                        P1 = Rx_al * Rz_th * [obj.Xm; obj.Ym; obj.Zm]
                        Xm1 = P1(1);
                        Ym1 = P1(2);
                        Zm1 = P1(3);
                        
                        obj.Xm=Xm1;
                        obj.Ym=Ym1;
                        obj.Zm=Zm1;
                        
                        XPixel = Xm1*propXPixel
                        YPixel = Ym1
                        ZPixel = Zm1*propZPixel
                        
                        import java.awt.Robot;
                        import java.awt.event.*;
                        robot = Robot;
                        robot.mouseMove(screensize(3)/2 - XPixel, screensize(4)/2 + ZPixel);
                    case 'LatitudeLongitude'
                        [lat, long] = obj.sg.poslog();
                        data = [ lat, long];
                        ts = [];
                    case 'Altitude'
                        [~, ~, ~, data, ~, ts] = obj.sg.poslog();
                    case 'Speed'
                        [~, ~, data, ~, ~, ts] = obj.sg.poslog();
                    case 'Course'
                        [~, ~, ~, ~, data, ts] = obj.sg.poslog();
                end
                
                if isempty(data)
                    return
                end
                if size(data,1) < 3
                    return
                end

                try
                    obj.processDataImpl(data,ts);
                catch e
                    % If the axes is deleted, then the object should delete
                    % itself automatically.
                    if strcmp(e.identifier,'MATLAB:class:InvalidHandle')
                        delete(obj)
                        return
                    end
                end
            catch
            end
        end
    end

    properties(GetAccess = private,SetAccess = private)
        updateTimer
        hLines
        isAxisCreated
        isSensorGroupCreated
        
        Xm
        Ym
        Zm
    end
        
    methods (Access=private)
        function info = getSensorInfo(obj)
            switch obj.sensorName
                case 'Acceleration'
                    info.unitName = 'm/s^2';
                    info.YLimit = 'auto';
                    info.legendText = {'x','y','z'};
                case 'MagneticAzimuth'
                    info.unitName = 'degree';
                    info.YLimit = [0 360];
                    info.legendText = {'Magnetic'};
                case 'Speed'
                    info.unitName = 'm/s';
                    info.YLimit = 'auto';
                    info.legendText = {'Speed'};
                case 'Course'
                    info.unitName = 'degree';
                    info.YLimit = [0 360];
                    info.legendText = {'Magnetic'};
                case 'AngularVelocity'
                    info.unitName = 'rad/sec';
                    info.YLimit = 'auto';
                    info.legendText = {'x','y','z'};
                case 'Altitude'
                    info.unitName = 'm above sea level';
                    info.YLimit = 'auto';
                    info.legendText = {'Altitude'};
                case 'GeodeticPosition'
                    info.unitName = 'degree';
                    info.YLimit = 'auto';
                    info.legendText = {'Latitude','Longitude'};
                case 'Latitude'
                    info.unitName = 'degree';
                    info.YLimit = 'auto';
                    info.legendText = {'Latitude'};
                case 'Longitude'
                    info.unitName = 'degree';
                    info.YLimit = 'auto';
                    info.legendText = {'Longitude'};
                case 'MagneticField'
                    info.unitName = 'Tesla';
                    info.YLimit = 'auto';
                    info.legendText = {'x','y','z'};
                case 'Orientation'
                    info.unitName = 'degree';
                    info.YLimit = [0 360];
                    info.legendText = {'Azimuth','Roll','Pitch'};
                case 'Roll'
                    info.unitName = 'deg';
                    info.YLimit = [0 360];
                    info.legendText = {''};
                case 'Pitch'
                    info.unitName = 'deg';
                    info.YLimit = [0 360];
                    info.legendText = {''};
                case 'Yaw'
                    info.unitName = 'deg';
                    info.YLimit = [0 360];
                    info.legendText = {''};
                otherwise
                    info.unitName = 'Unknown';
                    info.YLimit = 'auto';
                    info.legendText = {''};
            end
        end
    end
end

