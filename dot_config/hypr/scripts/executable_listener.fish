#!/usr/bin/env fish

function handleLine
    if string match -rq '^(?<event>.*)>>(?<args>.*)$' -- "$argv"
        if string match -raq '(?<vars>[^,]*),?' -- "$args"
            handleEvent $event $vars
        end
    end
end

function handleEvent
    set -l event $argv[1]
    set -l vars $argv[2..]

    if test $LOG_EVENTS
        echo $event $vars
    end

    # make Firefox extension windows float
    if test $event = windowtitlev2 && string match -rq 'Extension.*Mozilla Firefox' -- "$vars[2]"
        hyprctl dispatch setfloating address:0x$vars[1]
    end
end

while true
    socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -l line
        handleLine "$line"
    end
end
