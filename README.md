# Open WebUI Local Setup for macOS

Automated setup scripts for installing and running Open WebUI with Ollama on macOS without Docker and without macOS Ollama Application. For example, Ollama App is not available on macOS Monterey as, by the October 2025, it is no longer supported. (Same with Docker).

## Overview

This repository contains scripts to easily deploy Open WebUI on multiple macOS machines without requiring Docker or the macOS Ollama Application. Open WebUI provides a user-friendly web interface for interacting with Ollama's local LLM models.

## Features

- No Docker required - uses Python virtual environment
- No macOS Ollama Application required - uses Ollama CLI via Homebrew
- Compatible with macOS Monterey and systems where Docker/Ollama App are not supported
- No admin privileges needed for installation (after dependencies are installed)
- Automated installation and setup
- Easy model backup and restore across machines
- Complete cleanup options
- Supports deployment on 10+ machines

## Quick Start

### For Users

1. **Check Dependencies** (one-time, requires admin)

   Ask your administrator to install the required dependencies listed in `DEPENDENCIES.md`:
   - Python 3.11+
   - Ollama (CLI via Homebrew)
   - Homebrew

2. **Install Open WebUI**
   ```bash
   ./install.sh
   ```

3. **Pull a Model**
   ```bash
   ollama pull llama3.2
   ollama pull jobautomation/OpenEuroLLM-Czech
   ```

4. **Start the Service**
   ```bash
   ./start.sh
   ```

5. **Access the Interface**

   Open your browser to: http://localhost:8080

### For Administrators

See `DEPENDENCIES.md` for the list of system dependencies to install.

Quick install command:
```bash
brew install python@3.11 ollama
```

## Documentation

- **DEPENDENCIES.md** - List of required system dependencies (for administrators)
- **USAGE.md** - Detailed usage guide with examples and troubleshooting
- **README.md** - This file

## Available Scripts

| Script | Description |
|--------|-------------|
| `install.sh` | Install Open WebUI in a virtual environment |
| `start.sh` | Start Ollama and Open WebUI services |
| `stop.sh` | Stop running services |
| `cleanup.sh` | Remove Open WebUI (keeps models) |
| `cleanup-full.sh` | Full cleanup including models |
| `model-backup.sh` | Backup Ollama models to portable archive |
| `models-restore.sh` | Restore models from backup archive |

## Deployment to Multiple Machines

To efficiently set up Open WebUI on multiple machines:

1. **On the first machine:**
   ```bash
   ./install.sh
   ollama pull llama3.2
   ollama pull jobautomation/OpenEuroLLM-Czech
   ./model-backup.sh
   ```

2. **Copy to other machines:**
   - Copy this entire directory
   - Copy the model backup from `model-backups/`

3. **On each target machine:**
   ```bash
   ./install.sh
   ./models-restore.sh model-backups/ollama-models-XXXXXX.tar.gz
   ./start.sh
   ```

This approach saves bandwidth and time by avoiding redundant model downloads.

## System Requirements

- **OS:** macOS Monterey (12.0) or higher
- **Python:** 3.11 or higher
- **Disk Space:** 5-10 GB minimum (more for additional models)
- **RAM:** 8 GB minimum (16 GB recommended)
- **Admin Access:** Only required for initial dependency installation

## Configuration

Configuration is stored in `.env` file (created by `install.sh`):

```bash
OLLAMA_BASE_URL=http://localhost:11434  # Ollama API endpoint
PORT=8080                                # Web interface port
DATA_DIR=./data                          # Data storage location
ENABLE_SIGNUP=True                       # Allow new user registration
```

Edit `.env` and restart services to apply changes.

## Troubleshooting

### Installation Issues

**Missing dependencies:**
```bash
./install.sh
```
The script will list any missing dependencies. Ask your administrator to install them.

**Python version too old:**
```bash
python3 --version
```
Should be 3.11 or higher. Ask your administrator to update Python.

### Runtime Issues

**Port already in use:**
Edit `.env` and change `PORT=8080` to another port, then restart.

**Can't connect to Ollama:**
Check if Ollama is running:
```bash
curl http://localhost:11434/api/tags
```

**No models available:**
Pull at least one model:
```bash
ollama pull llama3.2
```

See `USAGE.md` for more troubleshooting tips.

## File Structure

```
openwebui/
├── README.md                # This file
├── DEPENDENCIES.md          # System dependencies list
├── USAGE.md                 # Detailed usage guide
├── install.sh               # Installation script
├── start.sh                 # Start services
├── stop.sh                  # Stop services
├── cleanup.sh               # Cleanup (keep models)
├── cleanup-full.sh          # Full cleanup
├── model-backup.sh          # Backup models
├── models-restore.sh        # Restore models
├── .env                     # Configuration (created by install)
├── venv/                    # Python virtual environment
├── data/                    # User data and chats
└── model-backups/           # Model backup archives
```

## Security Notes

- Open WebUI runs locally on your machine
- By default, `ENABLE_SIGNUP=True` allows anyone with access to create accounts
- For production use, set `ENABLE_SIGNUP=False` in `.env` after creating your account
- The service is only accessible from localhost by default
- Models and data are stored in your user directory

## Support

- Open WebUI documentation: https://docs.openwebui.com/
- Ollama documentation: https://ollama.ai/
- For issues with these scripts, contact your system administrator

## License

These scripts are provided as-is for internal use. Open WebUI and Ollama have their own licenses - please refer to their respective documentation.
