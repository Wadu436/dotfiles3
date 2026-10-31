#!/bin/sh
# Now-playing line for hyprlock. Lives in a script because hyprlock's config
# parser reads playerctl's {{ }} template syntax as a math expression.
title=$(playerctl metadata title 2>/dev/null) || exit 0
artist=$(playerctl metadata artist 2>/dev/null)
printf '󰝚  %s%s\n' "$title" "${artist:+  ·  $artist}"
