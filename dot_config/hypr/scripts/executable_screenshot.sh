#!/bin/bash

# Set the screenshot directory and file name
DIR=~/Pictures/Screenshots
FILE="Screenshot-$(date +%m-%d-%YT%H:%M:%S)-$(head /dev/urandom | tr -dc a-f | head -c 4).png"
SAVE_TO="$DIR/$FILE"

# Create the Screenshots directory if it doesn't exist
mkdir -p $DIR

# Take a screenshot with grim (and slurp for selection)
grim -g "$(slurp -o -b '#ffffff20' -B '#ffffff20' -s '#ffffff40' -w 0 -d)" $SAVE_TO
# Send a notification if grim was successful
if [ $? -eq 0 ]; then
  notify-send -i "$SAVE_TO" "Screenshot captured" "Copied to clipboard\nSaved to $SAVE_TO"
  wl-copy <$DIR/$FILE
fi
