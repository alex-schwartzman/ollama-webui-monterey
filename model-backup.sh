#!/bin/bash

# Backup Ollama models to a portable archive
# Creates a tar.gz archive that can be transferred to other machines

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Ollama Models Backup${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

OLLAMA_MODELS_DIR="$HOME/.ollama/models"
BACKUP_DIR="./model-backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/ollama-models-${TIMESTAMP}.tar.gz"

# Check if models directory exists
if [ ! -d "$OLLAMA_MODELS_DIR" ]; then
    echo -e "${RED}Error: Ollama models directory not found at $OLLAMA_MODELS_DIR${NC}"
    echo -e "${YELLOW}Make sure Ollama is installed and you have pulled at least one model.${NC}"
    exit 1
fi

# Check if there are any models
if [ -z "$(ls -A $OLLAMA_MODELS_DIR)" ]; then
    echo -e "${YELLOW}No models found to backup.${NC}"
    echo -e "${YELLOW}Pull some models first: ollama pull llama3.2${NC}"
    exit 0
fi

# Show models that will be backed up
echo -e "${GREEN}Models to be backed up:${NC}"
ollama list

# Show size
SIZE=$(du -sh "$OLLAMA_MODELS_DIR" 2>/dev/null | cut -f1)
echo ""
echo -e "${YELLOW}Total size: $SIZE${NC}"
echo ""

read -p "Continue with backup? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Backup cancelled.${NC}"
    exit 0
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo ""
echo -e "${GREEN}Creating backup archive...${NC}"
echo -e "${YELLOW}This may take a while depending on the size of your models...${NC}"

# Create the archive
tar -czf "$BACKUP_FILE" -C "$HOME/.ollama" models

echo ""
echo -e "${GREEN}✓ Backup created successfully!${NC}"
echo ""
echo -e "${GREEN}Backup file: ${YELLOW}$BACKUP_FILE${NC}"

# Show backup size
BACKUP_SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
echo -e "${GREEN}Backup size: ${YELLOW}$BACKUP_SIZE${NC}"
echo ""
echo -e "${GREEN}To restore on another machine:${NC}"
echo "1. Copy ${YELLOW}$BACKUP_FILE${NC} to the target machine"
echo "2. Run: ${YELLOW}./models-restore.sh $BACKUP_FILE${NC}"
echo ""
