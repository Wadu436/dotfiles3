local cargo_bin = "/home/warre/.cargo/bin"
local local_bin = "/home/warre/.local/bin"
local path = os.getenv("PATH") or ""
if not path:find(cargo_bin, 1, true) then
	path = cargo_bin .. ":" .. path
end
if not path:find(local_bin, 1, true) then
	path = local_bin .. ":" .. path
end

local env = {
	XCURSOR_SIZE = "24",
	HYPRCURSOR_SIZE = "24",
	HYPRCURSOR_THEME = "rose-pine-hyprcursor",
	EDITOR = "nvim",
	PATH = path,

	-- AMD (radeonsi VA-API driver for hardware video decode/encode)
	LIBVA_DRIVER_NAME = "radeonsi",

	-- Electron: make all Electron 20+ apps use native Wayland by default
	ELECTRON_OZONE_PLATFORM_HINT = "wayland",

	GDK_BACKEND = "wayland,x11,*",
	SDL_VIDEODRIVER = "wayland,x11,windows",
	CLUTTER_BACKEND = "wayland",

	-- Qt
	QT_AUTO_SCREEN_SCALE_FACTOR = "1",
	QT_QPA_PLATFORM = "wayland;xcb",
	QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
	QT_QPA_PLATFORMTHEME = "qt6ct",
	-- Make Kirigami/QtQuick Controls apps (Haruna, etc.) load qqc2-desktop-style
	-- so they honor KColorScheme from ~/.config/kdeglobals
	QT_QUICK_CONTROLS_STYLE = "org.kde.desktop",
}

for k, v in pairs(env) do
	hl.env(k, v)
end
