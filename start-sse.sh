#!/bin/bash

# Start the 1MCP Agent in SSE mode
# This script starts the agent with Server-Sent Events (SSE) communication mode

cd "$(dirname "$0")"
echo "Starting 1MCP Agent in SSE mode..."

# Check if the agent is compiled
if [ ! -d "agent/build" ]; then
    echo "Error: Agent not compiled. Please run compile.sh first."
    exit 1
fi

# Check for configuration file
CONFIG_FILE="1mcp-config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file $CONFIG_FILE not found."
    exit 1
fi

# Start the agent in SSE mode on port 3051
cd agent
node build/index.js --config "../$CONFIG_FILE" --sse --port 3051
