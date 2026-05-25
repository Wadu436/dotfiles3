-- Autostart necessary processes (like notifications daemons, status bars, etc.)

local autostart = {
	"spotify",
	"discord --enable-features=WaylandWindowDecorations,VaapiVideoDecoder,VaapiVideoEncoder --disable-features=UseChromeOSDirectVideoDecoder",
	"nm-applet",
	"blueman-applet",
}

hl.on("hyprland.start", function()
	for _, cmd in ipairs(autostart) do
		hl.exec_cmd("uwsm app -- " .. cmd)
	end
end)

-- Minimize-to-tray on first window: Spotify and Discord both live in the system
-- tray but pop their main window on launch. Close that initial window so they
-- sit in the tray; the entry is cleared after firing so reopening from the tray
-- isn't intercepted. Hyprland has no native minimize, so close-to-tray is the
-- closest equivalent for apps that keep running headless.
local close_first_window = { Spotify = true, discord = true }
hl.on("window.open", function(w)
	if close_first_window[w.initial_class] then
		close_first_window[w.initial_class] = nil
		hl.exec_cmd("hyprctl dispatch closewindow address:" .. w.address)
	end
end)
