local dir = os.getenv("HOME") .. "/.config/hypr/hyprland"
local handle = io.popen('ls "' .. dir .. '"')
for file in handle:lines() do
    local mod = file:match("^(.+)%.lua$")
    if mod then
        pcall(require, "hyprland." .. mod)
    end
end
handle:close()
