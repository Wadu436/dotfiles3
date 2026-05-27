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

hl.config({
	binds = {
		drag_threshold = 10,
	},
})
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })           -- Move window by dragging with SUPER + LMB
hl.bind("SUPER + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true }) -- Resize window by dragging with SUPER + SHIFT + LMB

-- Utilities
hl.bind("SUPER + D", uwsm_launch('rofi -show drun -show-icons -run-command "uwsm app -- {cmd}"')) -- Application launcher
hl.bind("SUPER + Tab", uwsm_launch("rofi -show window -show-icons"))                              -- Application switcher
hl.bind("SUPER + Period", uwsm_launch("rofi -modi emoji -show emoji"))                            -- Emoji picker
hl.bind("SUPER + B", uwsm_launch("rofi-rbw"))                                                     -- Bitwarden picker
hl.bind("SUPER + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"))                 -- Screenshots
hl.bind("SUPER + Pause", hl.dsp.exec_cmd("swaync-client -t -sw"))                                 -- Toggle notification panel

hl.on("hyprland.start", function() hl.dispatch(uwsm_launch("clipse -listen")) end)
hl.bind("SUPER + V", uwsm_launch("kitty --class clipse -e clipse")) -- Clipboard manager

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
