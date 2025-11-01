# Dependencies to Install (Admin Required)

The following dependencies must be installed by an administrator before running the setup script.

## Required System Dependencies

### 1. Homebrew (if not already installed)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Python 3.11 or higher
```bash
brew install python@3.11

# Fix file permissions (Homebrew sometimes sets incorrect permissions)
chmod -R a+r /usr/local/Cellar/python@3.11/
```

### 3. Ollama
```bash
brew install ollama
```

## Optional Dependencies

### For Performance (Recommended)

```bash
# Install performance tools for better user experience
brew install pv pigz jq
```

- **pv** - Progress viewer for archive operations
- **pigz** - Parallel gzip for faster compression (uses multiple CPU cores)
- **jq** - JSON processor for accurate manifest parsing

### For Web Developers

**Node.js:**
```bash
brew install node
```

**Note:** Node.js is only required if you plan to build the Open WebUI frontend from source code for development purposes. When installing Open WebUI via pip (as done in this setup), it comes as a pre-built Python package with the frontend already bundled. You can use Open WebUI for LLM queries without Node.js installed.

## Verification Commands

After installation, verify the dependencies:

```bash
# Check Python version (should be 3.11+)
python3 --version

# Check Homebrew
brew --version

# Check Ollama
ollama --version
```

## Summary of Admin Commands

For quick copy-paste, here are all the commands in sequence:

```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install python@3.11 ollama

# Fix Python permissions (Homebrew sometimes sets incorrect permissions)
chmod -R a+r /usr/local/Cellar/python@3.11/

# Verify installations
python3 --version
ollama --version
```

## Disk Space Requirements

- Python 3.11: ~100 MB
- Ollama: ~500 MB (plus space for models)
- Open WebUI: ~500 MB (including virtual environment)
- Models: Varies (typically 4-7 GB per model)

**Total estimated space needed: 5-10 GB minimum**
