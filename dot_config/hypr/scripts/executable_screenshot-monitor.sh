#!/usr/bin/env fish

set -l DIR ~/Pictures/Screenshots
set -l FILE Screenshot-(date +%m-%d-%YT%H:%M:%S)-(head /dev/urandom | tr -dc a-f | head -c 4).png
set -l SAVE_TO "$DIR/$FILE"

mkdir -p $DIR

set -l OUTPUT (hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
test -z "$OUTPUT"; and exit 1

grim -o "$OUTPUT" $SAVE_TO

if test $status -eq 0
    wl-copy --type image/png < $SAVE_TO
    notify-send -i "$SAVE_TO" "Screenshot captured" "Copied to clipboard\nSaved to $SAVE_TO"
end
