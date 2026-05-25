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

-- XWayland drag-and-drop spawns transient empty-class/empty-title floating
-- windows that steal focus mid-drag. Match only those (don't widen the class/
-- title regex) and refuse focus so drags complete cleanly.
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

-- Firefox extension pop-outs (Bitwarden, etc.) get mapped with title "Mozilla
-- Firefox" and only rename to "Extension: <name> — Mozilla Firefox" *after*
-- mapping, so a static window_rule (evaluated at map time) misses them. Watch
-- title changes instead; float on the first match per address and remember it
-- so subsequent title churn inside the same popout doesn't toggle anything.
local extension_handled = {}
hl.on("window.close", function(w)
    if w then extension_handled[w.address] = nil end
end)
hl.on("window.title", function(w)
    if w and w.class == "firefox" and not extension_handled[w.address]
            and w.title and w.title:find("^Extension: ") then
        extension_handled[w.address] = true
        hl.dispatch(hl.dsp.window.float(w))
        hl.dispatch(hl.dsp.window.resize({ window = w, x = 1100, y = 1000 }))
    end
end)

hl.window_rule({
    match = {
        class = "com.saivert.pwvucontrol"
    },
    float = true,
    size = { 1000, 800 }
})

hl.window_rule({
    match = {
        class = "org.pulseaudio.pavucontrol"
    },
    float = true,
    size = { 1000, 800 }
})

hl.window_rule({
    match = {
        class = "nm-connection-editor"
    },
    float = true,
    size = { 900, 600 }
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
