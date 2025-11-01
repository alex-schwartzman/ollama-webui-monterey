# Open WebUI Usage Guide

This guide explains how to use the Open WebUI installation and management scripts.

## Prerequisites

Before using these scripts, ensure that an administrator has installed the required dependencies listed in `DEPENDENCIES.md`:
- Python 3.11+
- Ollama
- Homebrew

## Quick Start

### 1. Install Open WebUI

```bash
./install.sh
```

This will:
- Check that all dependencies are installed
- Create a Python virtual environment
- Install Open WebUI
- Create a configuration file (`.env`)
- Create a data directory

### 2. Pull Ollama Models

Before you can use Open WebUI, you need to download at least one model:

```bash
# Pull a model (examples)
ollama pull llama3.2           # ~4GB
ollama pull jobautomation/OpenEuroLLM-Czech          # ~4GB
ollama pull codellama        # ~4GB
ollama pull llama3.2:13b       # ~7GB (larger, more capable)

# List available models
ollama list
```

**Note:** Models are large files (4-7 GB each) and may take time to download.

### 3. Start Open WebUI

```bash
./start.sh
```

This will:
- Start Ollama if it's not already running
- Start Open WebUI
- Display the URL where you can access the interface (default: http://localhost:8080)

Press `Ctrl+C` to stop the server when you're done.

### 4. Access Open WebUI

Open your web browser and navigate to:
```
http://localhost:8080
```

On first access, you'll be prompted to create an account.

## Available Scripts

### `install.sh`
Installs Open WebUI in a virtual environment.

```bash
./install.sh
```

### `start.sh`
Starts Ollama and Open WebUI services.

```bash
./start.sh
```

The web interface will be available at http://localhost:8080 (or the port specified in `.env`).

### `stop.sh`
Stops Open WebUI and Ollama services.

```bash
./stop.sh
```

### `cleanup.sh`
Removes Open WebUI installation (keeps Ollama models).

```bash
./cleanup.sh
```

This removes:
- Virtual environment
- Data directory (chats, settings)
- Configuration file
- Log files

This does NOT remove:
- Ollama models
- System dependencies

### `cleanup-full.sh`
Full cleanup including Ollama models.

```bash
./cleanup-full.sh
```

This removes everything including all downloaded models. Use with caution!

### `model-backup.sh`
Creates a portable backup of your Ollama models.

```bash
./model-backup.sh
```

Backups are saved to `model-backups/` directory and can be transferred to other machines.

### `models-restore.sh`
Restores Ollama models from a backup.

```bash
./models-restore.sh <backup-file.tar.gz>
```

Example:
```bash
./models-restore.sh model-backups/ollama-models-20250101_120000.tar.gz
```

## Configuration

The `.env` file contains configuration options:

```bash
# Ollama API URL
OLLAMA_BASE_URL=http://localhost:11434

# Web interface port
PORT=8080

# Data directory
DATA_DIR=./data

# Enable user signup
ENABLE_SIGNUP=True

# Secret key for sessions
WEBUI_SECRET_KEY=<randomly generated>
```

You can edit this file to change settings, but you'll need to restart Open WebUI for changes to take effect.

## Common Tasks

### Changing the Port

Edit `.env` and change the `PORT` value:
```bash
PORT=3000
```

Then restart:
```bash
./stop.sh
./start.sh
```

### Using a Different Ollama Server

If Ollama is running on a different machine or port, edit `.env`:
```bash
OLLAMA_BASE_URL=http://other-machine:11434
```

### Viewing Logs

Logs are written to:
- `ollama.log` - Ollama service logs

You can view them with:
```bash
tail -f ollama.log
```

### Transferring Models to Multiple Machines

To avoid downloading models on each machine:

1. On the first machine, pull the models you need:
   ```bash
   ollama pull llama3.2
   ollama pull jobautomation/OpenEuroLLM-Czech
   ```

2. Create a backup:
   ```bash
   ./model-backup.sh
   ```

3. Copy the backup file from `model-backups/` to the other machines

4. On each target machine, after running `./install.sh`:
   ```bash
   ./models-restore.sh path/to/backup-file.tar.gz
   ```

This saves significant time and bandwidth when setting up multiple machines.

## Troubleshooting

### "Port already in use"

If port 8080 is already in use, either:
1. Change the port in `.env`
2. Stop the conflicting service

### "Ollama connection refused"

Make sure Ollama is running:
```bash
ollama serve
```

Or check if it's running on a different port/host and update `.env`.

### "No models available"

You need to pull at least one model:
```bash
ollama pull llama3.2
```

### Models not found after restore

Make sure you stopped any running Ollama service before restoring:
```bash
./stop.sh
./models-restore.sh <backup-file>
```

## File Structure

After installation, your directory will look like this:

```
openwebui/
├── DEPENDENCIES.md          # List of required dependencies
├── USAGE.md                 # This file
├── install.sh               # Installation script
├── start.sh                 # Start services
├── stop.sh                  # Stop services
├── cleanup.sh               # Clean installation
├── cleanup-full.sh          # Full cleanup with models
├── model-backup.sh          # Backup models
├── models-restore.sh        # Restore models
├── .env                     # Configuration (created by install.sh)
├── venv/                    # Python virtual environment
├── data/                    # User data (chats, settings)
├── model-backups/           # Model backups (created when backing up)
└── *.log, *.pid            # Runtime files
```

## Uninstallation

To completely remove Open WebUI and models:

```bash
./cleanup-full.sh
```

To remove just Open WebUI but keep models:

```bash
./cleanup.sh
```

System dependencies (Python, Ollama) must be removed by an administrator if needed.

## Getting Help

- Open WebUI documentation: https://docs.openwebui.com/
- Ollama documentation: https://ollama.ai/
- Report issues with these scripts: Contact your system administrator
