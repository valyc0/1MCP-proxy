# 1MCP Agent Setup

Questo documento fornisce istruzioni dettagliate su come compilare e avviare l'agente 1MCP utilizzando gli script forniti.

## Indice

- [Script Disponibili](#script-disponibili)
- [Struttura delle Directory](#struttura-delle-directory)
- [Proxy NGINX Opzionale](#proxy-nginx-opzionale)
- [Istruzioni di Utilizzo](#istruzioni-di-utilizzo)
- [File di Configurazione](#file-di-configurazione)
- [Risoluzione dei Problemi](#risoluzione-dei-problemi)
- [Risorse Aggiuntive](#risorse-aggiuntive)
- [Autenticazione e Token](#autenticazione-e-token)
- [Sviluppo e Debug](#sviluppo-e-debug)
- [Monitoraggio MCP con Inspector](#monitoraggio-mcp-con-inspector)

## Script Disponibili

Questa directory contiene sei script principali:

1. `compile.sh` - Script per clonare il repository e compilare il codice
2. `start-stdio.sh` - Script per avviare l'agente in modalità stdio
3. `start-sse.sh` - Script per avviare l'agente in modalità SSE (Server-Sent Events)
4. `docker-script/build.sh` - Script wrapper che builda e avvia l'agente come container Docker
5. `docker-script/build-image.sh` - Script per buildare l'immagine Docker dell'agente
6. `docker-script/run-container.sh` - Script per avviare l'agente come container Docker

## Struttura delle Directory

```
1MCP-proxy/
├── agent/                  # Repository clonato con codice compilato
├── nginx/                  # Configurazione proxy NGINX opzionale
│   ├── nginx.conf          # Configurazione NGINX
│   ├── start-nginx-proxy.sh # Script di avvio proxy
│   ├── stop-nginx-proxy.sh  # Script di stop proxy
│   ├── ssl/                # Certificati SSL (generati automaticamente)
│   └── README.md           # Documentazione dettagliata NGINX
├── docker-script/          # Script per Docker build e run
│   ├── build.sh            # Script wrapper per buildare e avviare container Docker
│   ├── build-image.sh      # Script per buildare solo l'immagine Docker
│   └── run-container.sh    # Script per avviare solo il container Docker
├── 1mcp-config.json        # File di configurazione dell'agente
├── compile.sh              # Script di compilazione
├── start-stdio.sh          # Script per avvio in modalità stdio
├── start-sse.sh            # Script per avvio in modalità SSE
└── README.md               # Questo file
```

## Proxy NGINX Opzionale

Il servizio 1MCP Agent può essere utilizzato direttamente o tramite un proxy NGINX opzionale che fornisce:

- **HTTPS** con certificati SSL self-signed
- **Autenticazione** Bearer Token
- **Logging** centralizzato
- **Security headers**

### Modalità di Connessione

#### 🔹 Connessione Diretta (Raccomandata per sviluppo)

```json
{
  "mcpServers": {
    "1mcp-agent": {
      "url": "http://localhost:3051/sse"
    }
  }
}
```

#### 🔹 Tramite Proxy NGINX HTTP (Con autenticazione)

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

#### 🔹 Tramite Proxy NGINX HTTPS (Massima sicurezza)

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

### Avvio del Proxy NGINX

```bash
# 1. Avvia il servizio 1MCP Agent
./start-sse.sh

# 2. In un altro terminale, avvia il proxy NGINX (opzionale)
cd nginx
./start-nginx-proxy.sh

# 3. Ferma il proxy quando non serve più
./stop-nginx-proxy.sh
```

### Porte Utilizzate

- **3051**: Servizio 1MCP Agent (backend principale)
- **4080**: HTTP con Bearer Token (tramite NGINX)
- **4443**: HTTPS con Bearer Token (tramite NGINX)

### Quando Usare il Proxy NGINX

**✅ Usa il proxy NGINX quando:**
- Hai bisogno di autenticazione Bearer Token
- Vuoi HTTPS per sicurezza
- Devi esporre il servizio pubblicamente
- Hai bisogno di logging avanzato

**✅ Usa la connessione diretta quando:**
- Stai sviluppando localmente
- Vuoi semplicità di configurazione
- Stai facendo debug o test
- Non hai requisiti di sicurezza particolari

> 📋 **Documentazione completa**: Vedi `nginx/README.md` per istruzioni dettagliate su configurazione, troubleshooting e personalizzazione del proxy NGINX.

## Istruzioni di Utilizzo

### 1. Compilazione

Per clonare il repository e compilare il codice:

```bash
./compile.sh
```

Questo script:
- Clona il repository 1MCP Agent da `https://github.com/1mcp-app/agent.git` (o lo aggiorna se già esistente)
- Installa tutte le dipendenze necessarie
- Compila il codice sorgente

### 2. Avvio in Modalità stdio

Per avviare l'agente utilizzando la comunicazione stdio:

```bash
./start-stdio.sh
```

Questa modalità è utile quando l'agente deve comunicare attraverso i flussi standard di input/output.

### 3. Avvio in Modalità SSE

Per avviare l'agente utilizzando la comunicazione SSE (Server-Sent Events):

```bash
./start-sse.sh
```

La modalità SSE è preferibile quando l'agente deve inviare aggiornamenti in tempo reale a client web.

### 4. Utilizzo con Docker

Ci sono tre script per gestire l'agente con Docker:

#### Script wrapper (build e run insieme)

```bash
./docker-script/build.sh [PORT] [CONFIG_PATH] [IMAGE_NAME] [CONTAINER_NAME]
```

Questo script esegue in sequenza `build-image.sh` e `run-container.sh` con i parametri forniti.

#### Solo build dell'immagine Docker

```bash
./docker-script/build-image.sh [IMAGE_NAME]
```

Parametri (opzionali):
- `IMAGE_NAME`: Nome dell'immagine Docker (default: ghcr.io/1mcp-app/agent)

Questo script:
- Verifica se la directory agent esiste e, se necessario, clona il repository
- Builda l'immagine Docker dall'agent

#### Solo run del container Docker

```bash
./docker-script/run-container.sh [PORT] [CONFIG_PATH] [IMAGE_NAME] [CONTAINER_NAME]
```

Parametri (tutti opzionali):
- `PORT`: Porta su cui il container esporrà il servizio (default: 3051)
- `CONFIG_PATH`: Percorso al file di configurazione locale (default: /config/1mcp-config.json)
- `IMAGE_NAME`: Nome dell'immagine Docker (default: ghcr.io/1mcp-app/agent)
- `CONTAINER_NAME`: Nome del container (default: 1mcp-agent)

Questo script:
- Rimuove eventuali container esistenti con lo stesso nome
- Avvia un nuovo container con le variabili d'ambiente configurate
- Monta il file di configurazione locale nel container

Esempio di uso completo:
```bash
./docker-script/build.sh 3052 /path/to/my-config.json my-1mcp-image my-1mcp-container
```

Esempio di build separata e poi run:
```bash
./docker-script/build-image.sh my-custom-image
./docker-script/run-container.sh 3053 /path/to/config.json my-custom-image my-container
```

## File di Configurazione

Entrambi gli script di avvio utilizzano il file `1mcp-config.json` presente nella directory principale. Assicurati che questo file esista e contenga la configurazione corretta prima di avviare l'agente.

Esempio di configurazione base:
```json
{
  "agent": {
    "name": "1MCP Agent",
    "description": "Model Context Protocol Agent",
    "version": "1.0.0"
  },
  "servers": [
    {
      "name": "Filesystem Server",
      "id": "filesystem-server"
    }
  ]
}
```

## Risoluzione dei Problemi

Se riscontri problemi:

### Problemi Generali
1. Verifica che Node.js sia installato correttamente
2. Assicurati che il file di configurazione `1mcp-config.json` esista e sia formattato correttamente
3. Controlla i permessi di esecuzione degli script (usa `chmod +x *.sh` se necessario)
4. Verifica i log di errore generati durante l'esecuzione

### Problemi di Connessione
- **Errore 502 Bad Gateway**: Il servizio 1MCP Agent non è avviato su localhost:3051
- **Errore SSL/TLS**: Se usi HTTPS, aggiungi `"rejectUnauthorized": false` alla configurazione
- **Errore 401 Unauthorized**: Bearer token mancante o errato quando usi il proxy NGINX
- **Porta occupata**: Cambia porta con `--port` o verifica che non ci siano altri servizi in ascolto

### Debug con Proxy NGINX
Se stai usando il proxy NGINX e hai problemi:
```bash
# Verifica lo stato del proxy
docker ps | grep nginx-mcp-proxy

# Controlla i logs del proxy
docker logs -f nginx-mcp-proxy

# Testa direttamente il servizio backend
curl http://localhost:3051/health

# Testa il proxy senza autenticazione
curl http://localhost:4080/health
```

> 📋 Per problemi specifici del proxy NGINX, consulta `nginx/README.md`

## Risorse Aggiuntive

- [Documentazione 1MCP Agent](https://github.com/microsoft/1mcp-agent)
- [Specifiche Model Context Protocol](https://github.com/microsoft/model-context-protocol)
npx -y @1mcp/agent --transport stdio

# Mostra tutte le opzioni disponibili
npx -y @1mcp/agent --help
```

> **Nota importante**: Quando esegui `npx -y @1mcp/agent` senza opzioni aggiuntive, il server si avvia in modalità SSE e rimane in ascolto in background. Potrebbe sembrare che non succeda nulla poiché non ci sono output significativi nel terminale, ma il server è effettivamente in esecuzione e in ascolto sulla porta predefinita 3050. Per verificare che il server sia in esecuzione, puoi:
>
> 1. Controllare i processi attivi: `ps aux | grep 1mcp`
> 2. Verificare se la porta è in ascolto: `netstat -tulpn | grep 3050`
> 3. Testare il server con una richiesta curl: `curl http://localhost:3050/health`
> 4. Aprire nel browser: `http://localhost:3050/health`
>
> Se hai bisogno di maggiore feedback, puoi aggiungere l'opzione `--verbose` o `-v` per ottenere più informazioni:
>
> ```bash
> npx -y @1mcp/agent --verbose
> ```
>
> Se il server non sembra avviarsi correttamente, controlla che:
> 1. La porta 3050 non sia già in uso da un'altra applicazione
> 2. I server MCP configurati siano accessibili
> 3. Il file di configurazione (se specificato) sia valido

### Utilizzando l'eseguibile compilato

Dopo aver compilato l'applicazione, puoi eseguirla direttamente:

```bash
# Dal percorso del progetto
./build/index.js --config /workspace/db-ready/1mcp-config.json
```

### Esecuzione da directory specifica

Se hai bisogno di eseguire l'applicazione da una directory specifica, come nell'ambiente di workspace, puoi utilizzare il seguente comando:

```bash
# Esecuzione dalla directory agent con porta personalizzata 3051
cd /workspace/db-ready/agent && node build/index.js --config /workspace/db-ready/1mcp-config.json --port 3051
```

Questo comando naviga alla directory dell'agent, esegue il file JavaScript compilato utilizzando node, specifica il percorso del file di configurazione e imposta la porta HTTP su 3051.

### Avvio in Modalità SSE (HTTP)

La modalità SSE (Server-Sent Events) è la modalità di default e permette a più client di connettersi al server 1MCP Agent tramite HTTP. È ideale per scenari in cui hai bisogno di servire più client contemporaneamente.

```bash
# Avvio base in modalità SSE sulla porta predefinita (3050)
npx -y @1mcp/agent

# Avvio in modalità SSE con porta personalizzata
npx -y @1mcp/agent --port 3051

# Avvio in modalità SSE con file di configurazione specifico
npx -y @1mcp/agent --config /workspace/db-ready/1mcp-config.json

# Avvio in modalità SSE con autenticazione abilitata
npx -y @1mcp/agent --auth

# Avvio in modalità SSE filtrando solo i server con tag specifici
npx -y @1mcp/agent --tags "filesystem,memory"
```

Una volta avviato in modalità SSE, puoi configurare i tuoi client (come VS Code) per connettersi al server 1MCP Agent. 

#### Configurazione VS Code - Connessione Diretta

Nel file `settings.json` o `mcp_settings.json` di VS Code:

```json
{
  "mcp": {
    "servers": {
      "1mcp-agent": {
        "url": "http://localhost:3050/sse"
      }
    }
  }
}
```

#### Configurazione VS Code - Tramite Proxy NGINX

Se hai configurato il proxy NGINX (vedi sezione [Proxy NGINX Opzionale](#proxy-nginx-opzionale)):

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

> 💡 **Nota**: La porta predefinita è 3050, ma negli esempi di questo progetto viene spesso usata la porta 3051. Assicurati di usare la porta corretta specificata quando avvii il servizio.

### Avvio in Modalità stdio

La modalità stdio è pensata per essere utilizzata quando un client come un editor di codice (es. VS Code, Cursor) avvia il server come processo figlio e comunica con esso attraverso lo standard input/output. Questa modalità è generalmente utilizzata quando il server viene integrato in un'altra applicazione.

```bash
# Avvio base in modalità stdio
npx -y @1mcp/agent --transport stdio

# Avvio in modalità stdio con file di configurazione specifico
npx -y @1mcp/agent --transport stdio --config /workspace/db-ready/1mcp-config.json

# Avvio in modalità stdio filtrando solo i server con tag specifici
npx -y @1mcp/agent --transport stdio --tags "filesystem,memory"
```

Quando utilizzi la modalità stdio, tipicamente non hai bisogno di avviare manualmente il server, poiché sarà il client a farlo. Tuttavia, per scopi di test e debug, puoi avviarlo manualmente e interagire con esso tramite stdin/stdout.

### Opzioni Disponibili

- `--transport, -t`: Scegli il tipo di trasporto ("stdio" o "http", default: "http")
- `--config, -c`: Usa un file di configurazione specifico
- `--port, -P`: Cambia la porta HTTP (default: 3050)
- `--host, -H`: Cambia l'host HTTP (default: localhost)
- `--tags, -g`: Filtra i server per tag
- `--pagination, -p`: Abilita la paginazione per le liste client/server (booleano, default: false)
- `--auth`: Abilita l'autenticazione (OAuth 2.1) (booleano, default: false)
- `--session-ttl`: Tempo di scadenza della sessione in minuti (numero, default: 1440)
- `--session-storage-path`: Percorso personalizzato per l'archiviazione della sessione (stringa, default: undefined)
- `--help, -h`: Mostra aiuto

## Autenticazione e Token

### Generazione del Token

Quando abiliti l'autenticazione con il flag `--auth`, 1MCP Agent genera automaticamente un token di accesso che verrà mostrato nell'output del server:

```bash
# Avvio con autenticazione abilitata
npx -y @1mcp/agent --auth --config /workspace/db-ready/1mcp-config.json

# Output esempio:
# Server started on http://localhost:3050
# Authentication enabled
# Access token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Utilizzo del Token

Il token generato deve essere utilizzato dai client per autenticarsi al server. Configura il tuo client (come VS Code) nel seguente modo:

```json
{
  "mcp": {
    "servers": {
      "1mcp-agent": {
        "url": "http://localhost:3050/sse",
        "headers": {
          "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        }
      }
    }
  }
}
```

### Configurazione della Sessione

Puoi personalizzare le impostazioni di autenticazione:

```bash
# Impostare un TTL personalizzato per la sessione (in minuti)
npx -y @1mcp/agent --auth --session-ttl 60

# Specificare un percorso personalizzato per l'archiviazione della sessione
npx -y @1mcp/agent --auth --session-storage-path /path/to/sessions
```

**Importante**: Conserva il token generato in modo sicuro poiché sarà necessario per tutte le comunicazioni con il server autenticato.

## File di Configurazione 1mcp-config.json

Il file `/workspace/db-ready/1mcp-config.json` è un esempio di configurazione per 1MCP Agent. Ecco come è strutturato:

```json
{
  "mcpServers": {
    "postgres-server": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://postgres:postgres@localhost:5432/mydb"
      ],
      "tags": ["database", "postgres"],
      "disabled": true
    },
    "filesystem-server": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspace/db-ready"],
      "tags": ["filesystem", "files"],
      "disabled": false
    },
    "memory-server": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "tags": ["memory", "storage"],
      "disabled": true
    }
  }
}
```

### Componenti del File di Configurazione

- `mcpServers`: Un oggetto che contiene la configurazione per tutti i server MCP che 1MCP Agent gestirà.
  - Chiave (es. `postgres-server`): Nome del server, usato per identificare il server.
  - `command`: Il comando da eseguire per avviare il server.
  - `args`: Gli argomenti da passare al comando.
  - `tags`: Tag che descrivono le capacità del server (usati per il filtraggio).
  - `disabled`: Se `true`, il server non sarà avviato.

### Configurazione dei Server

Per aggiungere un nuovo server MCP alla configurazione:

1. Aggiungi una nuova chiave all'oggetto `mcpServers` con un nome descrittivo per il server.
2. Specifica il `command` e gli `args` necessari per avviare il server.
3. Aggiungi `tags` appropriati per descrivere le capacità del server.
4. Imposta `disabled` a `false` per abilitare il server o `true` per disabilitarlo.

### Utilizzo dei Tag

I tag aiutano a controllare quali server MCP sono disponibili per diversi client. Possono essere usati per filtrare i server quando si avvia 1MCP Agent:

```bash
# Avvia solo i server con il tag "filesystem"
npx -y @1mcp/agent --config /workspace/db-ready/1mcp-config.json --tags "filesystem"
```

## Sviluppo e Debug

### Modalità Sviluppo

Per lo sviluppo con ricompilazione automatica:

```bash
pnpm watch
```

Per eseguire il server in modalità sviluppo:

```bash
pnpm dev
```

### Debug

Puoi usare [MCP Inspector](https://github.com/modelcontextprotocol/inspector) per il debug, disponibile come script del pacchetto:

```bash
pnpm inspector
```

L'Inspector fornirà un URL per accedere agli strumenti di debug nel tuo browser.

### Monitoraggio MCP con Inspector

Per monitorare e analizzare i server MCP in tempo reale, puoi utilizzare l'MCP Inspector direttamente tramite npx:

```bash
npx @modelcontextprotocol/inspector
```

Questo comando avvia una web app locale che permette di:
- Ispezionare tutti i server MCP configurati
- Monitorare le comunicazioni in tempo reale
- Testare tool e resource dei server
- Visualizzare la struttura dei dati scambiati
- Debug delle configurazioni

L'Inspector è particolarmente utile durante lo sviluppo per verificare che i server MCP siano configurati correttamente e per testare le loro funzionalità.

### Source Maps

Questo progetto utilizza [source-map-support](https://www.npmjs.com/package/source-map-support) per migliorare gli stack trace. Quando esegui il server, gli stack trace faranno riferimento ai file sorgente TypeScript originali invece che ai file JavaScript compilati, rendendo il debug molto più semplice.
