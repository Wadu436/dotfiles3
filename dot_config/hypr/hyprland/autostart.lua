-- Autostart necessary processes (like notifications daemons, status bars, etc.)

local autostart = {
	"spotify & sleep 0.5 && hyprctl dispatch closewindow class:Spotify",
	"discord --start-minimized",
	"nm-applet",
	"blueman-applet",
}

hl.on("hyprland.start", function()
	for _, cmd in ipairs(autostart) do
		hl.exec_cmd("uwsm app -- " .. cmd)
	end
end)
