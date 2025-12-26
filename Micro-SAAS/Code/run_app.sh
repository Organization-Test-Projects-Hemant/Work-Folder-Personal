#!/bin/bash

# Start the Flask server in the background
cd /workspaces/Work-Folder-Personal/Micro-SAAS/Code
/workspaces/Work-Folder-Personal/.venv/bin/python app.py &

# Wait for server to start
sleep 3

# Open the browser
"$BROWSER" http://127.0.0.1:5000/index

# Wait for user to finish
echo "Server is running at http://127.0.0.1:5000/index"
echo "Press Ctrl+C to stop the server"

# Keep the script running
wait