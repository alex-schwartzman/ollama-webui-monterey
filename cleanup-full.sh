#!/bin/bash

# Full cleanup including Ollama models
# This calls cleanup.sh and additionally removes Ollama models

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}============================================${NC}"
echo -e "${RED}Open WebUI Full Cleanup (WITH MODELS)${NC}"
echo -e "${RED}============================================${NC}"
echo ""
echo -e "${RED}WARNING: This will remove:${NC}"
echo -e "${RED}  - Virtual environment (venv/)${NC}"
echo -e "${RED}  - Data directory (data/)${NC}"
echo -e "${RED}  - Configuration file (.env)${NC}"
echo -e "${RED}  - Log files (*.log, *.pid)${NC}"
echo -e "${RED}  - ALL Ollama models (~/.ollama/models/)${NC}"
echo ""
echo -e "${YELLOW}This is a destructive operation and cannot be undone!${NC}"
echo -e "${YELLOW}Models can be large (4-7 GB each) and take time to re-download.${NC}"
echo ""
read -p "Type 'DELETE EVERYTHING' to confirm: " CONFIRM

if [ "$CONFIRM" != "DELETE EVERYTHING" ]; then
    echo -e "${YELLOW}Full cleanup cancelled.${NC}"
    exit 0
fi

echo ""

# Run standard cleanup
if [ -f "cleanup.sh" ]; then
    echo -e "${GREEN}Running standard cleanup...${NC}"
    # Run cleanup.sh with automatic 'yes' confirmation
    echo "yes" | bash cleanup.sh
else
    echo -e "${RED}Error: cleanup.sh not found${NC}"
    exit 1
fi

# Remove Ollama models
OLLAMA_MODELS_DIR="$HOME/.ollama/models"
if [ -d "$OLLAMA_MODELS_DIR" ]; then
    echo -e "${RED}Removing Ollama models directory...${NC}"

    # Show size before deletion
    SIZE=$(du -sh "$OLLAMA_MODELS_DIR" 2>/dev/null | cut -f1)
    echo -e "${YELLOW}Deleting $SIZE of model data...${NC}"

    rm -rf "$OLLAMA_MODELS_DIR"
    echo -e "${GREEN}✓ Ollama models removed${NC}"
else
    echo -e "${YELLOW}ℹ Ollama models directory not found${NC}"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Full Cleanup Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${GREEN}To reinstall:${NC}"
echo "1. Run: ${YELLOW}./install.sh${NC}"
echo "2. Pull models: ${YELLOW}ollama pull llama2${NC} (or other models)"
echo ""
