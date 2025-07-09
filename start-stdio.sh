#!/bin/bash

# Start the 1MCP Agent in stdio mode
# This script starts the agent with stdio communication mode

cd "$(dirname "$0")"
echo "Starting 1MCP Agent in stdio mode..."

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

# Start the agent in stdio mode
cd agent
node build/index.js --config "../$CONFIG_FILE" --stdio
