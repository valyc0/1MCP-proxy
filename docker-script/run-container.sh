#!/bin/bash

# Script to run the 1MCP agent Docker container

# Set default values for environment variables
DEFAULT_PORT=3051
DEFAULT_HOST="0.0.0.0"
DEFAULT_CONFIG_PATH="/config/1mcp-config.json"
DEFAULT_IMAGE_NAME="ghcr.io/1mcp-app/agent"
DEFAULT_CONTAINER_NAME="1mcp-agent"

# Parse command line arguments
PORT=${1:-$DEFAULT_PORT}
CONFIG_PATH=${2:-$DEFAULT_CONFIG_PATH}
IMAGE_NAME=${3:-$DEFAULT_IMAGE_NAME}
CONTAINER_NAME=${4:-$DEFAULT_CONTAINER_NAME}

# Check if a container with the same name is already running
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container $CONTAINER_NAME already exists, removing it..."
    docker rm -f $CONTAINER_NAME
fi

echo "Running Docker container: $CONTAINER_NAME"

# Run the Docker container with the specified environment variables
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:$PORT \
    -v $(dirname "$CONFIG_PATH"):"/config" \
    -e ONE_MCP_TRANSPORT="http" \
    -e ONE_MCP_PORT="$PORT" \
    -e ONE_MCP_HOST="$DEFAULT_HOST" \
    -e ONE_MCP_CONFIG="$DEFAULT_CONFIG_PATH" \
    -e ONE_MCP_PAGINATION="false" \
    -e ONE_MCP_AUTH="false" \
    -e ONE_MCP_SESSION_TTL="1440" \
    $IMAGE_NAME

if [ $? -ne 0 ]; then
    echo "Error: Failed to start Docker container"
    exit 1
fi

echo "Docker container started successfully: $CONTAINER_NAME"
echo "Port mapping: $PORT:$PORT"
echo "Config file mounted from: $CONFIG_PATH"
echo "Environment variables set:"
echo "  ONE_MCP_TRANSPORT: http"
echo "  ONE_MCP_PORT: $PORT"
echo "  ONE_MCP_HOST: $DEFAULT_HOST"
echo "  ONE_MCP_CONFIG: $DEFAULT_CONFIG_PATH"
echo "  ONE_MCP_PAGINATION: false"
echo "  ONE_MCP_AUTH: false"
echo "  ONE_MCP_SESSION_TTL: 1440"

echo ""
echo "To check container logs, run: docker logs $CONTAINER_NAME"
echo "To stop the container, run: docker stop $CONTAINER_NAME"
echo "To start the container, run: docker start $CONTAINER_NAME"
