#!/bin/bash
set -e

# Start the Node.js application
echo "🚀 Starting the Framework application..."

# Start the backend server in the background
echo "🔧 Starting backend server..."
npm start &

# Wait a moment to ensure backend is initializing
sleep 3

# Start the frontend server
echo "🌐 Starting frontend server..."
npm run client
