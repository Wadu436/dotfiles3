#!/usr/bin/env bash
# Now-playing label for hyprlock: title, then artist on a second line, each cut
# to fit the lock screen's left column. Lives in a script because hyprlock's
# config parser reads playerctl's {{ }} template syntax as a math expression.
title=$(playerctl metadata title 2>/dev/null) || exit 0
artist=$(playerctl metadata artist 2>/dev/null)

# ~40 characters fit the column at the label's font size
fit() {
    local s=$1 max=$2
    if ((${#s} > max)); then
        printf '%s…' "${s:0:max-1}"
    else
        printf '%s' "$s"
    fi
}

printf '󰝚  %s\n' "$(fit "$title" 38)"
[[ -n $artist ]] && printf '    %s\n' "$(fit "$artist" 38)"
exit 0
