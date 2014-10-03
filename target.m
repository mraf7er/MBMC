function target(fig_handle, event, target_handles)
% function target should be attached to WindowButtonMotionFcn
handles = guidata(fig_handle);
pos = get(fig_handle, 'currentpoint');  % get mouse location on figure
x = pos(1); 
y = pos(2);                 % assign locations to x and y


global prev_target tStart;

target_id = [];
% find out which one the mouse is on top of right now 
for i = 1:length(target_handles)
    % get position information of the uicontrol
    object_handle = target_handles{i};
    bounds = get(object_handle,'position');
    lx = bounds(1); 
    ly = bounds(2);
    lw = bounds(3); 
    lh = bounds(4);
    if (x >= lx && x <= (lx + lw) && y >= ly && y <= (ly + lh))
        target_id = i;
        if (prev_target ~= 1 && prev_target ~= 2 && prev_target ~= 3 && prev_target ~= 4 && prev_target ~= 5 && prev_target ~= 6 && prev_target ~= 7 && prev_target ~= 8)
            tStart = tic;
            prev_target = i;
        end
        break;
    end
end
for i = 1:length(target_handles)
    object_handle = target_handles{i};
    if target_id == i 
        % set enable to off so that the whole static text field is hotspot
        set(object_handle, 'enable', 'off');
        set(object_handle, 'string', 'IN');
        set(object_handle, 'backgroundcolor', 'yellow');
        setfigptr('hand', handles.fig_gravity);
        tE = toc(tStart);
        if tE > 3
            % set enable to off so that the whole static text field is hotspot
            set(object_handle, 'enable', 'off');
            set(object_handle, 'string', 'OK');
            set(object_handle, 'backgroundcolor', 'green');
            setfigptr('hand', handles.fig_gravity);
        end
    else
        % re-enable the uicontrol      
        set(object_handle, 'enable', 'on');
        set(object_handle,'string', 'OUT');
        set(object_handle, 'backgroundcolor', 'red');
    end
end
if isempty(target_id)
    setfigptr('arrow', handles.fig_gravity);
    prev_target = -1;
end

end % end of target function