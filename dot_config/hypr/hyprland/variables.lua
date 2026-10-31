-- #####################
-- ### LOOK AND FEEL ###
-- #####################

-- # Refer to https://wiki.hypr.land/Configuring/Variables/

hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 4,

		border_size = 2,

		col = {
			-- Rosé Pine: iris → foam gradient for focus, highlight_med for inactive
			active_border = { colors = { "rgba(c4a7e7ee)", "rgba(9ccfd8ee)" }, angle = 45 },
			inactive_border = "rgba(403d52aa)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 8,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(191724ee)", -- Rosé Pine base
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 1,

			vibrancy = 0.1696,
		},
	},
	dwindle = {
		preserve_split = true,
	},
	-- Tabbed window groups (SUPER+G), styled like the Quickshell island:
	-- iris → foam border on the focused group, a flat Rosé Pine tab bar on top.
	group = {
		col = {
			border_active = { colors = { "rgba(c4a7e7ee)", "rgba(9ccfd8ee)" }, angle = 45 },
			border_inactive = "rgba(403d52aa)",
			border_locked_active = { colors = { "rgba(f6c177ee)", "rgba(ebbcbaee)" }, angle = 45 },
			border_locked_inactive = "rgba(403d52aa)",
		},
		groupbar = {
			font_family = "JetBrainsMono Nerd Font",
			font_size = 11,
			font_weight_active = "bold",
			height = 20,
			indicator_height = 0,
			gradients = true,
			rounding = 8,
			gradient_rounding = 8,
			gaps_in = 3,
			gaps_out = 3,
			text_color = "rgba(191724ff)",
			text_color_inactive = "rgba(908caaff)",
			col = {
				active = "rgba(c4a7e7ee)",
				inactive = "rgba(26233acc)",
				locked_active = "rgba(f6c177ee)",
				locked_inactive = "rgba(26233acc)",
			},
		},
	},
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		-- Let apps raise their window when asked, e.g. kitty focusing the
		-- window a clicked notification came from.
		focus_on_activate = true,
	},
})

hl.config({ animations = { enabled = true } })
-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
-- Workspaces slide sideways in the direction of the workspace number (Hyprland
-- picks left/right from the ids), on the same spring the windows and the
-- Quickshell island use. The scratchpad drops in vertically instead.
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.5, spring = "easy", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4.5, spring = "easy", style = "slidevert" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
