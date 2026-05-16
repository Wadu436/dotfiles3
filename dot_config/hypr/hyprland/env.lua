local path = os.getenv("PATH")

local env = {
	XCURSOR_SIZE = "24",
	HYPRCURSOR_SIZE = "24",
	HYPRCURSOR_THEME = "rose-pine-hyprcursor",
	EDITOR = "nvim",
	PATH = path .. ":/home/warre/.cargo/bin",

	-- nvidia
	LIBVA_DRIVER_NAME = "nvidia",
	__GLX_VENDOR_LIBRARY_NAME = "nvidia",

	GDK_BACKEND = "wayland,x11,*",
	SDL_VIDEODRIVER = "wayland,x11,windows",
	CLUTTER_BACKEND = "wayland",

	XDG_CURRENT_DESKTOP = "Hyprland",
	XDG_SESSION_TYPE = "wayland",
	XDG_SESSION_DESKTOP = "Hyprland",

	-- Qt
	QT_AUTO_SCREEN_SCALE_FACTOR = "1",
	QT_QPA_PLATFORM = "wayland;xcb",
	QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
	QT_QPA_PLATFORMTHEME = "qt6ct",
}

for k, v in pairs(env) do
	hl.env(k, v)
end
