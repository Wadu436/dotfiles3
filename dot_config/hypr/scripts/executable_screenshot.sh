#!/usr/bin/env fish

set -l DIR ~/Pictures/Screenshots
set -l FILE Screenshot-(date +%m-%d-%YT%H:%M:%S)-(head /dev/urandom | tr -dc a-f | head -c 4).png
set -l SAVE_TO "$DIR/$FILE"

mkdir -p $DIR

set -l region (slurp -o -b '#ffffff20' -B '#ffffff20' -s '#ffffff40' -w 0 -d)
echo $region
grim -g "$region" $SAVE_TO

if test $status -eq 0
    notify-send -i "$SAVE_TO" "Screenshot captured" "Copied to clipboard\nSaved to $SAVE_TO"
    wl-copy < $SAVE_TO
end
