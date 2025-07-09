#!/bin/bash

# Wrapper script to build and run the 1MCP agent Docker container

# Set default values for environment variables
DEFAULT_PORT=3051
DEFAULT_CONFIG_PATH="/config/1mcp-config.json"
DEFAULT_IMAGE_NAME="ghcr.io/1mcp-app/agent"
DEFAULT_CONTAINER_NAME="1mcp-agent"

# Parse command line arguments
PORT=${1:-$DEFAULT_PORT}
CONFIG_PATH=${2:-$DEFAULT_CONFIG_PATH}
IMAGE_NAME=${3:-$DEFAULT_IMAGE_NAME}
CONTAINER_NAME=${4:-$DEFAULT_CONTAINER_NAME}

# Make the scripts executable
chmod +x "$(dirname "$0")/build-image.sh"
chmod +x "$(dirname "$0")/run-container.sh"

# Build the Docker image
"$(dirname "$0")/build-image.sh" "$IMAGE_NAME"
if [ $? -ne 0 ]; then
    echo "Error: Failed to build Docker image"
    exit 1
fi

# Run the Docker container
"$(dirname "$0")/run-container.sh" "$PORT" "$CONFIG_PATH" "$IMAGE_NAME" "$CONTAINER_NAME"
if [ $? -ne 0 ]; then
    echo "Error: Failed to run Docker container"
    exit 1
fi

echo "Build and run completed successfully!"
