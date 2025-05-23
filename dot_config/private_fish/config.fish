source ~/.config/fish/functions.fish
source ~/.config/fish/aliases.fish
source ~/.config/fish/secrets.fish
source ~/.config/fish/machine.fish

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -Ux COREPACK_ENABLE_AUTO_PIN 0

set -gx EDITOR nvim
set -gx TG_NO_AUTO_APPROVE "true"

# jj completions 
COMPLETE=fish jj | source

# Log every command
function log_command --on-event fish_preexec
    set timestamp (date "+%Y-%m-%dT%H:%M:%S%z")
    echo "$timestamp | $argv" >> ~/.fish_command_log
end

