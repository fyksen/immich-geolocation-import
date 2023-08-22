#!/bin/bash

# Folder to monitor
MONITOR_DIR="/app/destination"

# Command to run when a change is detected
COMMAND_TO_RUN="/usr/local/bin/immich upload -y --delete -k $API_KEY -s $SERVER_URL/api /app/destination"

# Ensure inotify-tools is installed
if ! command -v inotifywait &> /dev/null; then
    echo "Error: inotifywait is not installed."
    echo "Please install inotify-tools."
    exit 1
fi

# Keep track of whether we're currently processing a batch of files
processing=false

# Loop indefinitely
while true; do
    # Wait for changes in the folder. This will block until a change occurs.
    event=$(inotifywait -q -e modify,create,moved_to,moved_from,delete -t 5 --format '%e' "$MONITOR_DIR")

    # If no event detected, skip
    if [ -z "$event" ]; then
        continue
    fi

    # Print event for debugging
    echo "Detected event: $event"
    
    # If files are being removed, it's the immich process. Skip.
    if [[ "$event" =~ "MOVED_FROM" || "$event" =~ "DELETE" ]]; then
        continue
    fi

    # Only act if not already processing
    if [ "$processing" = false ]; then
        processing=true
        sleep 2

        # Check for any new events for a certain duration. If new events are still happening, wait again.
        while inotifywait -q -e modify,create,moved_to -t 10 "$MONITOR_DIR"; do
            sleep 2
        done

        # Run the command after you're confident there are no more new changes
        eval "$COMMAND_TO_RUN"

        processing=false
    fi
done
