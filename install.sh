#!/bin/bash

# Open WebUI Installation Script for macOS
# This script does NOT require admin privileges
# Dependencies must be installed first (see DEPENDENCIES.md)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Open WebUI Installation Script for macOS${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# Array to track missing dependencies
MISSING_DEPS=()

# Check if Python is installed
echo -e "${GREEN}Checking Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 is not installed${NC}"
    MISSING_DEPS+=("Python 3.11+")
else
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')

    # Check Python version
    REQUIRED_VERSION="3.11"
    if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
        echo -e "${RED}✗ Python $PYTHON_VERSION found, but 3.11+ is required${NC}"
        MISSING_DEPS+=("Python 3.11+ (currently: $PYTHON_VERSION)")
    else
        echo -e "${GREEN}✓ Python $PYTHON_VERSION found${NC}"
    fi
fi

# Check if Ollama is installed
echo -e "${GREEN}Checking Ollama...${NC}"
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}✗ Ollama is not installed${NC}"
    MISSING_DEPS+=("Ollama")
else
    OLLAMA_VERSION=$(ollama --version 2>&1 | head -n1)
    echo -e "${GREEN}✓ $OLLAMA_VERSION found${NC}"
fi

# Check if Node.js is installed (optional)
echo -e "${GREEN}Checking Node.js (optional)...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}ℹ Node.js is missing, so this will be sufficient only for the LLM usage, not for web development on top of it${NC}"
else
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js $NODE_VERSION found${NC}"
fi

# Exit if any dependencies are missing
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}============================================${NC}"
    echo -e "${RED}Missing Dependencies!${NC}"
    echo -e "${RED}============================================${NC}"
    echo ""
    echo -e "${YELLOW}The following dependencies are missing:${NC}"
    for dep in "${MISSING_DEPS[@]}"; do
        echo -e "${YELLOW}  - $dep${NC}"
    done
    echo ""
    echo -e "${YELLOW}Please ask your administrator to install the missing dependencies.${NC}"
    echo -e "${YELLOW}See DEPENDENCIES.md for installation instructions.${NC}"
    echo ""
    exit 1
fi

echo ""
echo -e "${GREEN}All dependencies satisfied!${NC}"
echo ""

# Create virtual environment
echo -e "${GREEN}Creating Python virtual environment...${NC}"
if [ -d "venv" ]; then
    echo -e "${YELLOW}Virtual environment already exists. Skipping creation.${NC}"
else
    python3 -m venv venv
    echo -e "${GREEN}✓ Virtual environment created successfully.${NC}"
fi

# Activate virtual environment
echo -e "${GREEN}Activating virtual environment...${NC}"
source venv/bin/activate

# Upgrade pip
echo -e "${GREEN}Upgrading pip...${NC}"
pip install --upgrade pip --quiet

# Install Open WebUI
echo -e "${GREEN}Installing Open WebUI...${NC}"
pip install open-webui

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo -e "${GREEN}Creating .env configuration file...${NC}"
    cat > .env << EOF
# Open WebUI Configuration

# Ollama API URL (change if Ollama is running on a different host/port)
OLLAMA_BASE_URL=http://localhost:11434

# Open WebUI will run on this port
PORT=8080

# Data directory (where chats and settings are stored)
DATA_DIR=./data

# Enable signup (set to False in production)
ENABLE_SIGNUP=True

# Webui secret key (change this to a random string)
WEBUI_SECRET_KEY=$(openssl rand -hex 32)
EOF
    echo -e "${GREEN}✓ .env file created with default settings.${NC}"
else
    echo -e "${YELLOW}.env file already exists. Skipping creation.${NC}"
fi

# Create data directory
mkdir -p data
echo -e "${GREEN}✓ Data directory created.${NC}"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Pull Ollama models: ${YELLOW}ollama pull llama2${NC} (or other models)"
echo "2. Start services: ${YELLOW}./start.sh${NC}"
echo "3. Open your browser to: ${YELLOW}http://localhost:8080${NC}"
echo ""
echo -e "${GREEN}For more information, see USAGE.md${NC}"
echo ""
