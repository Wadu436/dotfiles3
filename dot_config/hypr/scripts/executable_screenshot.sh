#!/usr/bin/env fish

set -l DIR ~/Pictures/Screenshots
set -l FILE Screenshot-(date +%m-%d-%YT%H:%M:%S)-(head /dev/urandom | tr -dc a-f | head -c 4).png
set -l SAVE_TO "$DIR/$FILE"

mkdir -p $DIR

# Capture up front, so the image is the screen as it was at keypress time
set -l FULL (mktemp --suffix=.png)
if not grim $FULL
    rm -f $FULL
    exit 1
end

# Freeze the screen so the region is picked against what was captured
hyprpicker -r -z -d -q &
set -l PICKER $last_pid
sleep 0.2

set -l region (slurp -o -b '#ffffff20' -B '#ffffff20' -s '#ffffff40' -w 0 -d)
kill $PICKER 2>/dev/null

if test -z "$region"
    rm -f $FULL
    exit 0
end

# grim's canvas starts at the top-left of the monitor layout, which is not
# (0,0) when a monitor sits at a negative position -- slurp reports absolute
# layout coordinates, so subtract that origin to get pixels within the capture
set -l origin (hyprctl monitors -j | jq -r '[([.[].x]|min), ([.[].y]|min)] | @tsv' | string split \t)
set -l parts (string split ' ' -- $region)
set -l xy (string split ',' -- $parts[1])
set -l wh (string split 'x' -- $parts[2])
set -l geom (printf '%sx%s+%s+%s' $wh[1] $wh[2] (math -- "$xy[1] - $origin[1]") (math -- "$xy[2] - $origin[2]"))

magick $FULL -crop $geom +repage $SAVE_TO
set -l cropped $status
rm -f $FULL

if test $cropped -eq 0
    wl-copy --type image/png < $SAVE_TO
    notify-send -i "$SAVE_TO" "Screenshot captured" "Copied to clipboard\nSaved to $SAVE_TO"
end
