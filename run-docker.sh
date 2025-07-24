#!/bin/bash

# Script per avviare il container Docker con Node 22
# Mappa la directory corrente e avvia direttamente la build

echo "Avvio del container Docker con Node 22..."

docker run -it --rm \
  --name mcp-proxy-node \
  -p 3051:3051 \
  -v "$(pwd)":/app \
  -w /app \
  node:22-alpine \
  sh -c "
    echo 'Installing dependencies...' &&
    cd agent &&
    npm install &&
    echo 'Building project...' &&
    npm run build &&
    echo 'Starting 1MCP Agent in SSE mode...' &&
    node build/index.js --config ../1mcp-config.json --sse --port 3051 --host 0.0.0.0 --external-url https://0.0.0.0:3051
  "
