# NGINX Proxy per 1MCP Agent (Opzionale)

Questo setup configura un proxy NGINX opzionale con HTTPS e autenticazione Bearer Token per il servizio 1MCP Agent. 

**⚠️ NOTA**: L'uso di NGINX è **opzionale**. Il servizio 1MCP Age## Personalizzazione NGINX

### Cambiare il Bearer Token
Modifica la riga in `nginx.conf`:
```nginx
if ($http_authorization !~ "^Bearer IL-TUO-TOKEN-QUI$") {
```

### Cambiare le porte
Modifica le porte nel comando docker in `start-nginx-proxy.sh`:
```bash
-p 8080:80 \
-p 8081:4080 \
-p 8443:4443 \
```

## Troubleshooting

### Problemi comuni

**502 Bad Gateway**: Il servizio 1MCP Agent non è avviato
```bash
cd /workspace/db-ready/1MCP-proxy/agent && npm start
```

**SSL Certificate Error**: Usa `rejectUnauthorized: false` o passa a HTTP
```json
"rejectUnauthorized": false
```

**401 Unauthorized**: Bearer token mancante o errato
```json
"headers": {
  "Authorization": "Bearer mcp-token-secret-2025"
}
```ato direttamente senza proxy.

## Modalità di utilizzo

### Modalità 1: Connessione Diretta (Semplice)
```json
{
  "mcpServers": {
    "1mcp-agent": {
      "url": "http://localhost:3051/sse"
    }
  }
}
```

### Modalità 2: Tramite NGINX Proxy (Sicuro)
```json
{
  "mcpServers": {
    "1mcp-agent": {
      "url": "http://localhost:4080/sse",
      "headers": {
        "Authorization": "Bearer mcp-token-secret-2025"
      }
    }
  }
}
```

### Modalità 3: Tramite NGINX Proxy HTTPS (Più Sicuro)
```json
{
  "mcpServers": {
    "1mcp-agent": {
      "url": "https://localhost:4443/sse",
      "headers": {
        "Authorization": "Bearer mcp-token-secret-2025"
      },
      "rejectUnauthorized": false
    }
  }
}
```

## Configurazione NGINX (se usato)

- **Backend**: `http://localhost:3051/sse` (servizio 1MCP Agent)
- **Proxy HTTP**: `http://localhost:80` (redirect automatico a HTTPS)
- **Proxy HTTP MCP**: `http://localhost:4080` (con Bearer Token, senza SSL)
- **Proxy HTTPS**: `https://localhost:4443` (con Bearer Token e SSL)
- **Bearer Token**: `mcp-token-secret-2025`

## Come utilizzare

### Opzione A: Uso Diretto (Senza NGINX)

1. **Avviare il servizio 1MCP Agent**
```bash
cd /workspace/db-ready/1MCP-proxy/agent
npm start
# Il servizio sarà disponibile su http://localhost:3051/sse
```

2. **Configurare VS Code**
```json
{
  "mcpServers": {
    "1mcp-agent": {
      "url": "http://localhost:3051/sse"
    }
  }
}
```

### Opzione B: Uso con NGINX Proxy (Con Autenticazione)

1. **Avviare il servizio 1MCP Agent**
```bash
cd /workspace/db-ready/1MCP-proxy/agent
npm start
```

2. **Avviare NGINX Proxy**
```bash
cd /workspace/db-ready/1MCP-proxy/nginx
./start-nginx-proxy.sh
```

3. **Configurare VS Code** (scegli una delle opzioni)

**HTTP con Bearer Token** (consigliato):
```json
{
  "mcpServers": {
    "1mcp-agent": {
      "url": "http://localhost:4080/sse",
      "headers": {
        "Authorization": "Bearer mcp-token-secret-2025"
      }
    }
  }
}
```

**HTTPS con Bearer Token** (più sicuro):
```json
{
  "mcpServers": {
    "1mcp-agent": {
      "url": "https://localhost:4443/sse",
      "headers": {
        "Authorization": "Bearer mcp-token-secret-2025"
      },
      "rejectUnauthorized": false
    }
  }
}
```

### Test delle connessioni

**Test connessione diretta:**
```bash
curl http://localhost:3051/sse
```

**Test con NGINX HTTP:**
```bash
# Con Bearer Token (dovrebbe funzionare)
curl -H "Authorization: Bearer mcp-token-secret-2025" http://localhost:4080/sse

# Senza Bearer Token (dovrebbe restituire 401)
curl http://localhost:4080/sse

# Health check (senza autenticazione)
curl http://localhost:4080/health
```

**Test con NGINX HTTPS:**
```bash
# Con Bearer Token (dovrebbe funzionare)
curl -k -H "Authorization: Bearer mcp-token-secret-2025" https://localhost:4443/sse

# Senza Bearer Token (dovrebbe restituire 401)
curl -k https://localhost:4443/sse

# Health check (senza autenticazione)
curl -k https://localhost:4443/health
```

### 4. Fermare NGINX Proxy (se utilizzato)
```bash
./stop-nginx-proxy.sh
```

## Quando usare NGINX Proxy

### ✅ Usa NGINX quando:
- Vuoi autenticazione Bearer Token
- Hai bisogno di HTTPS per sicurezza
- Vuoi logging centralizzato
- Devi esporre il servizio pubblicamente
- Hai bisogno di rate limiting o altre funzionalità proxy

### ✅ Usa connessione diretta quando:
- Stai sviluppando localmente
- Non hai bisogno di autenticazione
- Vuoi semplicità di configurazione
- Stai facendo debug o test

## Configurazione VS Code

### Connessione Diretta (Semplice)
Nel tuo `mcp_settings.json` o `settings.json`:
```json
{
  "mcpServers": {
    "1mcp-agent": {
      "url": "http://localhost:3051/sse"
    }
  }
}
```

### Con NGINX HTTP (Con Autenticazione)
```json
{
  "mcpServers": {
    "1mcp-agent": {
      "url": "http://localhost:4080/sse",
      "headers": {
        "Authorization": "Bearer mcp-token-secret-2025"
      }
    }
  }
}
```

### Con NGINX HTTPS (Più Sicuro)
```json
{
  "mcpServers": {
    "1mcp-agent": {
      "url": "https://localhost:4443/sse",
      "headers": {
        "Authorization": "Bearer mcp-token-secret-2025"
      },
      "rejectUnauthorized": false
    }
  }
}
```

## Sicurezza (solo se usi NGINX)

- **Certificati SSL**: Vengono generati automaticamente certificati self-signed
- **Bearer Token**: `mcp-token-secret-2025` (personalizzabile in `nginx.conf`)
- **HTTPS Only**: HTTP viene automaticamente reindirizzato a HTTPS (su porta 80)
- **Security Headers**: Configurati header di sicurezza standard
- **Autenticazione**: Richiesta per tutti gli endpoint tranne `/health`

## Personalizzazione

### Cambiare il Bearer Token
Modifica la riga in `nginx.conf`:
```nginx
if ($http_authorization !~ "^Bearer IL-TUO-TOKEN-QUI$") {
```

### Cambiare le porte
Modifica le porte nel comando docker in `start-nginx-proxy.sh`:
```bash
-p 8080:80 \
-p 8443:4443 \
```

## Troubleshooting

### Verificare i logs NGINX
```bash
docker logs -f nginx-mcp-proxy
```

### Verificare che il servizio backend sia in ascolto
```bash
curl http://localhost:3051/health
```

### Verificare i certificati SSL
```bash
ls -la ssl/
```

### Ricreare i certificati SSL
```bash
rm -rf ssl/
./start-nginx-proxy.sh
```

## Porte utilizzate

- **3051**: Servizio 1MCP Agent (backend)
- **80**: HTTP redirect a HTTPS (solo con NGINX)
- **4080**: HTTP con Bearer Token (solo con NGINX)
- **4443**: HTTPS con Bearer Token (solo con NGINX)

## File del progetto

### File NGINX (opzionali)
- `nginx.conf` - Configurazione NGINX
- `start-nginx-proxy.sh` - Script di avvio
- `stop-nginx-proxy.sh` - Script di stop
- `ssl/nginx.crt` - Certificato SSL (generato automaticamente)
- `ssl/nginx.key` - Chiave privata SSL (generata automaticamente)

### File del servizio principale
- `../agent/` - Directory del servizio 1MCP Agent
- `../agent/package.json` - Configurazione Node.js
- `../agent/src/` - Codice sorgente del servizio
