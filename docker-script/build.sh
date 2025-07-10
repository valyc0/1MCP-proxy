#!/bin/bash

# Wrapper script to build and run the 1MCP agent Docker container

# Set default values for environment variables
DEFAULT_PORT=3051
DEFAULT_CONFIG_FILE="../1mcp-config.json"  # Relative to docker-script directory
DEFAULT_IMAGE_NAME="ghcr.io/1mcp-app/agent"
DEFAULT_CONTAINER_NAME="1mcp-agent"

# Parse command line arguments
PORT=${1:-$DEFAULT_PORT}
CONFIG_FILE=${2:-$DEFAULT_CONFIG_FILE}
IMAGE_NAME=${3:-$DEFAULT_IMAGE_NAME}
CONTAINER_NAME=${4:-$DEFAULT_CONTAINER_NAME}

# Convert relative path to absolute path
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_PATH="$(realpath "$SCRIPT_DIR/$CONFIG_FILE")"

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
