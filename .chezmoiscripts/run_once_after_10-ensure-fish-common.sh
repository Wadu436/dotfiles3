#!/bin/sh
# config.fish is machine-local and may already exist (fish writes a default on
# first start), so only ever append the source line — never rewrite the file.
set -eu

config="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
line='source ~/.config/fish/common.fish'

if [ ! -f "$config" ]; then
    mkdir -p "$(dirname "$config")"
    cat >"$config" <<'EOF'
### Machine-local fish config — untracked by chezmoi.
# Local paths and installer-injected config go here; shared config is common.fish.
EOF
    printf '\n# Shared config (chezmoi-managed)\n%s\n' "$line" >>"$config"
    echo "created fish config.fish sourcing common.fish"
    exit 0
fi

if grep -qF "$line" "$config"; then
    exit 0
fi

printf '\n# Shared config (chezmoi-managed)\n%s\n' "$line" >>"$config"
echo "ensured fish config.fish sources common.fish"
