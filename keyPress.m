function keyPress(fig_handle, event, handles)
global mouse Timer Xm Ym Zm SURF HCONTOUR;

AXES = handles{1};
OBJ = handles{2};

        
switch event.Key
    case 'c'
        set(AXES, 'Visible', 'off');
        set(SURF, 'Visible', 'off');
        set(HCONTOUR, 'Visible', 'off');
    case 'v'
        set(AXES, 'Visible', 'on');
        set(SURF, 'Visible', 'on');
        set(HCONTOUR, 'Visible', 'on');
        view(2); %az = 0, el = 90
    case 'm'
        Xm = 0;
        Ym = .55;
        Zm = 0;
        if isempty(mouse) || mouse == 0
            mouse = 1;
            Timer = timer(  'BusyMode','drop',...
                'ExecutionMode','fixedRate',...
                'Period',.1,...
                'StartDelay',0,...
                'ErrorFcn',@(src,event)handleError(OBJ,src,event),...
                'TimerFcn',@(src,event)handleUpdate(OBJ,src,event));
            start(Timer);
        end
    case 'f'
        if mouse == 1
            stop(Timer);
            delete(Timer);
        end
        mouse = 0;
end
end


function handleError(~,~,~)
% Ignore errors
end

function handleUpdate(obj,~,~)
global Xm Ym Zm;


angularVelocity = obj.AngularVelocity;

alpha = -(angularVelocity(1)-.0133)*.05;
theta = -(angularVelocity(3)-.0213)*.05;

screensize = get(0, 'screensize');
propXPixel = screensize(3)/.36;
propZPixel = screensize(4)/.20;

Rz_th = [cos(theta), -sin(theta), 0; ...
    sin(theta), cos(theta),  0; ...
    0,          0,           1];

Rx_al = [1,          0,           0; ...
    0,          cos(alpha),  -sin(alpha); ...
    0,          sin(alpha),  cos(alpha)];

P1 = Rx_al * Rz_th * [Xm; Ym; Zm];
Xm1 = P1(1);
Ym1 = P1(2);
Zm1 = P1(3);

Xm=Xm1;
Ym=Ym1;
Zm=Zm1;

XPixel = Xm1*propXPixel;
YPixel = Ym1;
ZPixel = Zm1*propZPixel;

import java.awt.Robot;
import java.awt.event.*;
robot = Robot;

robot.mouseMove(screensize(3)/2 - XPixel, screensize(4)/2 + ZPixel);

end
