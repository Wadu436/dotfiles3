hl.window_rule({
    match = {
        class = "clipse"
    },
    float = true,
    size = { 622, 652 },
    stay_focused = true
})

-- hl.window_rule({
--     name = "suppress-maximize-events",
--     match = {
--         class = ".*"
--     },
--     suppress_event = "maximize"
-- })

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false
    },
    no_focus = true
})

-- disable animations for slurp so grim doesn't capture it
hl.layer_rule({
    match = {
        namespace = "selection"
    },
    no_anim = true
})

hl.window_rule({
    match = {
        class = "com.saivert.pwvucontrol"
    },
    float = true
})

hl.window_rule({
    match = {
        class = "org.pulseaudio.pavucontrol"
    },
    float = true
})

hl.window_rule({
    match = {
        class = "steam",
        title = "Friends List"
    },
    float = true
})
hl.window_rule({
    match = {
        class = "steam",
        title = "Steam Settings"
    },
    float = true
})

hl.window_rule({
    match = {
        class = "steam_app_.*"
    },
    monitor = "DP-1",
    workspace = 10,
    fullscreen = true
})
