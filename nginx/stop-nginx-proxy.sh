#!/bin/bash

echo "🛑 Fermando NGINX Proxy..."

# Ferma e rimuove il container
docker stop nginx-mcp-proxy 2>/dev/null
docker rm nginx-mcp-proxy 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ NGINX Proxy fermato con successo"
else
    echo "⚠️  Container non trovato o già fermato"
fi

# Mostra i container in esecuzione
echo "📋 Container attivi:"
docker ps | grep nginx || echo "Nessun container nginx in esecuzione"
