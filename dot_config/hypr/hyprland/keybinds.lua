-- ###################
-- ### KEYBINDINGS ###
-- ###################

-- # See https://wiki.hypr.land/Configuring/Keywords/
-- $mainMod = SUPER # Sets "Windows" key as main modifier
local function uwsm_launch(command)
	return hl.dsp.exec_cmd("uwsm app -- " .. command)
end

-- Hyprland management
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("uwsm stop")) -- Force quit Hyprland

-- Window management
hl.bind("SUPER + Q", hl.dsp.window.close())                                 -- Close active window
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill())                          -- Kill active window
hl.bind("SUPER + Space", hl.dsp.window.float())                             -- Toggle floating/tiled for active window
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))                          -- Swap split of the active window in dwindle layout
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))       -- Toggle fullscreen for active window
hl.bind("SUPER + SHIFT + Comma", hl.dsp.workspace.move({ monitor = "l" }))  -- Move active workspace to the left monitor
hl.bind("SUPER + SHIFT + Period", hl.dsp.workspace.move({ monitor = "r" })) -- Move active workspace to the right monitor

-- Shift focus in the given direction with SUPER + direction
hl.bind("SUPER + Left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "d" }))

-- Move window in the given direction with SUPER + SHIFT + direction
hl.bind("SUPER + SHIFT + Left", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + Up", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + Down", hl.dsp.window.move({ direction = "d" }))

for i = 1, 10 do
	local key = i % 10 -- 10 maps to 0
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind("ALT + Tab", hl.dsp.focus({ workspace = "previous" }))                             -- Switch between the last 2 active workspaces

hl.bind("SUPER + Minus", hl.dsp.workspace.toggle_special("scratchpad"))                    -- Toggle scratchpad workspace
hl.bind("SUPER + SHIFT + Minus", hl.dsp.window.move({ workspace = "special:scratchpad" })) -- Move active window to scratchpad workspace

-- Tabbed groups
hl.bind("SUPER + G", hl.dsp.group.toggle())                                    -- Turn the active window into a group (or dissolve its group)
hl.bind("SUPER + SHIFT + G", hl.dsp.window.move({ out_of_group = true }))      -- Pull the active window out of its group
hl.bind("SUPER + bracketleft", hl.dsp.group.prev())                            -- Previous tab in group
hl.bind("SUPER + bracketright", hl.dsp.group.next())                           -- Next tab in group
hl.bind("SUPER + CTRL + Left", hl.dsp.window.move({ into_group = "l" }))       -- Move the active window into the group on its left
hl.bind("SUPER + CTRL + Right", hl.dsp.window.move({ into_group = "r" }))      -- Move the active window into the group on its right
hl.bind("SUPER + CTRL + Up", hl.dsp.window.move({ into_group = "u" }))         -- Move the active window into the group above it
hl.bind("SUPER + CTRL + Down", hl.dsp.window.move({ into_group = "d" }))       -- Move the active window into the group below it

hl.config({
	binds = {
		drag_threshold = 10,
	},
})
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })           -- Move window by dragging with SUPER + LMB
hl.bind("SUPER + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true }) -- Resize window by dragging with SUPER + SHIFT + LMB

-- Utilities
hl.bind("SUPER + D", hl.dsp.exec_cmd("qs ipc call shell launcher apps"))                         -- Application launcher (Quickshell island)
hl.bind("SUPER + Tab", hl.dsp.exec_cmd("qs ipc call shell launcher windows"))                    -- Window switcher (Quickshell island)
hl.bind("SUPER + Period", hl.dsp.exec_cmd("qs ipc call shell launcher emoji"))                    -- Emoji picker (Quickshell island)
hl.bind("SUPER + B", hl.dsp.exec_cmd("qs ipc call shell launcher passwords"))                    -- Bitwarden picker (Quickshell island)
hl.bind("Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot-monitor.sh"))                 -- Screenshot the focused monitor
hl.bind("SUPER + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"))                 -- Screenshot a region (freezes, then crops)
hl.bind("SUPER + Pause", hl.dsp.exec_cmd("qs ipc call shell toggleDashboard"))                    -- Toggle dashboard (Quickshell island)
hl.bind("SUPER + slash", hl.dsp.exec_cmd("qs ipc call shell launcher keys"))                     -- Keybind cheat sheet (Quickshell island)

-- clipse records clipboard history; the Quickshell launcher's clipboard tab reads it
hl.on("hyprland.start", function() hl.dispatch(uwsm_launch("clipse -listen")) end)
hl.bind("SUPER + V", hl.dsp.exec_cmd("qs ipc call shell launcher clips")) -- Clipboard history (Quickshell island)

-- Launch things
hl.bind("SUPER + Return", uwsm_launch("kitty")) -- Terminal
hl.bind("SUPER + E", uwsm_launch("thunar"))     -- File manager

-- Laptop multimedia keys (Volume/Brightness)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ repeatable = true, locked = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"),
	{ repeatable = true, locked = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ repeatable = true, locked = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ repeatable = true, locked = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { repeatable = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeatable = true, locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
