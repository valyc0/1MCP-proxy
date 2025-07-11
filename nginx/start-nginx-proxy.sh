#!/bin/bash

echo "🚀 Avvio NGINX Proxy per 1MCP Agent..."
echo "Configurazione:"
echo "  - HTTP: http://localhost:80 (redirect a HTTPS)"
echo "  - HTTP MCP: http://localhost:4080 (con Bearer Token)"
echo "  - HTTPS: https://localhost:4443"
echo "  - Backend: http://localhost:3051/sse"
echo "  - Bearer Token: mcp-token-secret-2025"
echo ""

# Crea directory per i certificati SSL se non esiste
mkdir -p $(pwd)/ssl

# Genera certificati SSL self-signed se non esistono
if [ ! -f "$(pwd)/ssl/nginx.crt" ] || [ ! -f "$(pwd)/ssl/nginx.key" ]; then
    echo "📋 Generazione certificati SSL self-signed..."
    
    # Crea il certificato SSL
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout $(pwd)/ssl/nginx.key \
        -out $(pwd)/ssl/nginx.crt \
        -subj "/C=IT/ST=Italy/L=City/O=Organization/OU=OrgUnit/CN=localhost"
    
    echo "✅ Certificati SSL generati"
else
    echo "✅ Certificati SSL già presenti"
fi

# Testa la configurazione nginx
echo "🔧 Test configurazione nginx..."
docker run --rm \
    -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
    -v $(pwd)/ssl:/etc/nginx/ssl:ro \
    nginx:alpine nginx -t

if [ $? -ne 0 ]; then
    echo "❌ Errore nella configurazione nginx"
    exit 1
fi

echo "✅ Configurazione nginx OK"

# Verifica che il servizio 1MCP sia in ascolto
echo "🔍 Verifica che il servizio 1MCP sia in ascolto su localhost:3051..."
if ! curl -s http://localhost:3051/health > /dev/null 2>&1; then
    echo "⚠️  ATTENZIONE: Il servizio 1MCP non sembra essere in ascolto su localhost:3051"
    echo "   Assicurati che il servizio sia avviato prima di continuare"
    echo "   Puoi avviarlo con: cd /workspace/db-ready/1MCP-proxy/agent && npm start"
    echo ""
fi

# Ferma eventuali container nginx esistenti
echo "🧹 Pulizia container precedenti..."
docker stop nginx-mcp-proxy 2>/dev/null || true
docker rm nginx-mcp-proxy 2>/dev/null || true

# Avvia NGINX in Docker
echo "🐳 Avvio container NGINX..."
docker run -d \
    --name nginx-mcp-proxy \
    --network host \
    -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
    -v $(pwd)/ssl:/etc/nginx/ssl:ro \
    -p 80:80 \
    -p 4080:4080 \
    -p 4443:4443 \
    nginx:alpine

# Verifica che il container sia avviato
if [ $? -eq 0 ]; then
    echo "✅ NGINX Proxy avviato con successo!"
    echo ""
    echo "📡 Endpoint disponibili:"
    echo "  - HTTP:  http://localhost (redirect a HTTPS)"
    echo "  - HTTP MCP: http://localhost:4080 (con Bearer Token, senza SSL)"
    echo "  - HTTPS: https://localhost:4443"
    echo "  - Health HTTP: http://localhost:4080/health (senza autenticazione)"
    echo "  - Health HTTPS: https://localhost:4443/health (senza autenticazione)"
    echo ""
    echo "🔐 Autenticazione Bearer Token:"
    echo "  Authorization: Bearer mcp-token-secret-2025"
    echo ""
    echo "📋 Esempio di utilizzo con curl:"
    echo "  HTTPS: curl -k -H 'Authorization: Bearer mcp-token-secret-2025' https://localhost:4443/sse"
    echo "  HTTP:  curl -H 'Authorization: Bearer mcp-token-secret-2025' http://localhost:4080/sse"
    echo ""
    echo "📊 Per vedere i logs:"
    echo "  docker logs -f nginx-mcp-proxy"
    echo ""
    echo "🛑 Per fermare:"
    echo "  docker stop nginx-mcp-proxy && docker rm nginx-mcp-proxy"
else
    echo "❌ Errore nell'avvio del container NGINX"
    exit 1
fi

# Mostra lo status del container
echo "📋 Status container:"
docker ps | grep nginx-mcp-proxy
