#!/bin/bash

# Start Open WebUI and Ollama services

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Starting Open WebUI Services${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo -e "${RED}Error: Virtual environment not found.${NC}"
    echo -e "${YELLOW}Please run ./install.sh first.${NC}"
    exit 1
fi

# Check if Ollama is running
echo -e "${GREEN}Checking Ollama status...${NC}"
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${YELLOW}Ollama is not running. Starting Ollama...${NC}"

    # Start Ollama in the background
    nohup ollama serve > ollama.log 2>&1 &
    echo $! > ollama.pid

    # Wait for Ollama to be ready
    for i in {1..10}; do
        if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Ollama started successfully${NC}"
            break
        fi
        if [ $i -eq 10 ]; then
            echo -e "${RED}Error: Ollama failed to start${NC}"
            echo -e "${YELLOW}Check ollama.log for details${NC}"
            exit 1
        fi
        sleep 1
    done
else
    echo -e "${GREEN}✓ Ollama is already running${NC}"
fi

# Activate virtual environment
source venv/bin/activate

# Load environment variables from .env if it exists
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo -e "${GREEN}Starting Open WebUI...${NC}"
echo ""
echo -e "${GREEN}Open WebUI will be available at:${NC}"
echo -e "${GREEN}  http://localhost:${PORT:-8080}${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
echo ""

# Start Open WebUI (this runs in foreground)
open-webui serve
