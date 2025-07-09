#!/bin/bash

# Script to build the 1MCP agent Docker image

# Set default values for environment variables
DEFAULT_IMAGE_NAME="ghcr.io/1mcp-app/agent"
AGENT_REPO="https://github.com/1mcp-app/agent.git"

# Parse command line arguments
IMAGE_NAME=${1:-$DEFAULT_IMAGE_NAME}

# Check if agent directory exists
AGENT_DIR="$(dirname "$0")/../agent"
if [ ! -d "$AGENT_DIR" ]; then
    echo "Agent directory not found. Cloning repository..."
    cd "$(dirname "$0")/.."
    git clone $AGENT_REPO agent
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone agent repository"
        exit 1
    fi
    echo "Repository cloned successfully"
else
    echo "Using existing agent directory"
fi

echo "Building Docker image: $IMAGE_NAME"

# Navigate to the directory containing the Dockerfile (in the agent subdirectory)
cd "$AGENT_DIR"

# Build the Docker image
docker build -t $IMAGE_NAME .

if [ $? -ne 0 ]; then
    echo "Error: Docker build failed"
    exit 1
fi

echo "Docker image built successfully: $IMAGE_NAME"
