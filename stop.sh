#!/bin/bash

# Stop Open WebUI and Ollama services

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Stopping Open WebUI Services${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# Stop Open WebUI
echo -e "${GREEN}Stopping Open WebUI...${NC}"
if pgrep -f "open-webui" > /dev/null; then
    pkill -f "open-webui"
    echo -e "${GREEN}✓ Open WebUI stopped${NC}"
else
    echo -e "${YELLOW}ℹ Open WebUI is not running${NC}"
fi

# Stop Ollama if it was started by start.sh
echo -e "${GREEN}Stopping Ollama...${NC}"
if [ -f "ollama.pid" ]; then
    OLLAMA_PID=$(cat ollama.pid)
    if ps -p $OLLAMA_PID > /dev/null 2>&1; then
        kill $OLLAMA_PID
        rm ollama.pid
        echo -e "${GREEN}✓ Ollama stopped${NC}"
    else
        echo -e "${YELLOW}ℹ Ollama process not found (PID: $OLLAMA_PID)${NC}"
        rm ollama.pid
    fi
else
    # Check if Ollama is running but wasn't started by our script
    if pgrep -f "ollama serve" > /dev/null; then
        echo -e "${YELLOW}ℹ Ollama is running but wasn't started by start.sh${NC}"
        echo -e "${YELLOW}  Run 'pkill -f \"ollama serve\"' manually to stop it${NC}"
    else
        echo -e "${YELLOW}ℹ Ollama is not running${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Done.${NC}"
