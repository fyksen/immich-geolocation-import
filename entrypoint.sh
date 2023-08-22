#!/bin/bash

trap "echo 'Shutting down...'; exit 0" SIGINT SIGTERM
# Check that environment variables are set.
if [ -z "$API_KEY" ]; then
    echo "Error: API_KEY environment variable not set!"
    exit 1
fi

if [ -z "$SERVER_URL" ]; then
    echo "Error: SERVER_URL environment variable not set!"
    exit 1
fi

# Start the first process (gunicorn)
gunicorn -b 0.0.0.0:8000 app:app &

# Start the second process (monitor.sh). Assuming it's also a bash script.
./immich-upload.sh &

# If either process exits, this entrypoint script will exit, which will cause the container to exit.
# We can use the `wait` command to make the script wait for any of its child processes to complete.
wait -n
