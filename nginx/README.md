# NGINX Proxy per 1MCP Agent (Opzionale)

Questo setup configura un proxy NGINX opzionale con HTTPS e autenticazione Bearer Token per il servizio 1MCP Agent. 

**⚠️ NOTA**: L'uso di NGINX è **opzionale**. Il servizio 1MCP Age## Personalizzazione NGINX

### Personalizzazione NGINX

### Configurazione tramite parametri dello script
```bash
# Token personalizzato con porte predefinite
./start-nginx-proxy.sh "your-secret-token-2025"

# Token e porte personalizzate
./start-nginx-proxy.sh "your-token" 9080 9443

# Solo porte personalizzate (token predefinito)
./start-nginx-proxy.sh "mcp-token-secret-2025" 9080 9443
```

### Cambiare manualmente il Bearer Token nel template
Modifica la riga in `nginx.conf.template`:
```nginx
if ($http_authorization !~ "^Bearer YOUR-TOKEN-HERE$") {
```

### Cambiare manualmente le porte nel template
Modifica le righe in `nginx.conf.template`:
```nginx
listen YOUR_HTTP_PORT;
listen YOUR_HTTPS_PORT ssl;
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

# Avvio con configurazione predefinita
./start-nginx-proxy.sh

# Avvio con Bearer token personalizzato
./start-nginx-proxy.sh "my-custom-token-2025"

# Avvio con token e porte personalizzate
./start-nginx-proxy.sh "my-token" 8080 8443
```

**Parametri dello script:**
- `BEARER_TOKEN`: Token di autenticazione (default: `mcp-token-secret-2025`)
- `HTTP_PORT`: Porta HTTP per MCP (default: `4080`)
- `HTTPS_PORT`: Porta HTTPS per MCP (default: `4443`)

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

### File del progetto

### File NGINX (opzionali)
- `nginx.conf.template` - Template di configurazione NGINX
- `nginx.conf` - Configurazione NGINX generata (non modificare manualmente)
- `start-nginx-proxy.sh` - Script di avvio con parametri personalizzabili
- `stop-nginx-proxy.sh` - Script di stop
- `ssl/nginx.crt` - Certificato SSL (generato automaticamente)
- `ssl/nginx.key` - Chiave privata SSL (generata automaticamente)

### File del servizio principale
- `../agent/` - Directory del servizio 1MCP Agent
- `../agent/package.json` - Configurazione Node.js
- `../agent/src/` - Codice sorgente del servizio
