#!/bin/bash

# Compilation script for 1MCP agent
# This script clones the repository and builds the code

set -e  # Exit on any error

echo "===== 1MCP Agent Compilation Script ====="

REPO_NAME="agent"
REPO_URL="https://github.com/1mcp-app/agent.git"

# Clone or update the repository
if [ -d "$REPO_NAME" ]; then
    echo "Repository directory already exists. Updating..."
    cd "$REPO_NAME"
    git pull
    cd ..
else
    echo "Cloning repository from $REPO_URL..."
    git clone "$REPO_URL"
fi

# Navigate to the repository directory
cd "$REPO_NAME"

# Install dependencies
echo "Installing dependencies..."
npm install

# Build the project
echo "Building the project..."
npm run build

echo "===== Compilation Complete ====="
echo "The 1MCP agent has been successfully built."
