#!/bin/bash

# Restore Ollama models from a backup archive
# Usage: ./models-restore.sh <backup-file.tar.gz>

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Ollama Models Restore${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# Check if backup file argument is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No backup file specified${NC}"
    echo ""
    echo -e "${YELLOW}Usage: ./models-restore.sh <backup-file.tar.gz>${NC}"
    echo ""
    echo -e "${GREEN}Available backups:${NC}"
    if [ -d "model-backups" ] && [ "$(ls -A model-backups/*.tar.gz 2>/dev/null)" ]; then
        ls -lh model-backups/*.tar.gz
    else
        echo -e "${YELLOW}  No backups found in model-backups/ directory${NC}"
    fi
    echo ""
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Error: Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Error: Ollama is not installed${NC}"
    echo -e "${YELLOW}Please ask your administrator to install Ollama first.${NC}"
    exit 1
fi

OLLAMA_DIR="$HOME/.ollama"
OLLAMA_MODELS_DIR="$OLLAMA_DIR/models"

# Show backup file info
BACKUP_SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
echo -e "${GREEN}Backup file: ${YELLOW}$BACKUP_FILE${NC}"
echo -e "${GREEN}Backup size: ${YELLOW}$BACKUP_SIZE${NC}"
echo ""

# Warn if models already exist
if [ -d "$OLLAMA_MODELS_DIR" ] && [ "$(ls -A $OLLAMA_MODELS_DIR 2>/dev/null)" ]; then
    echo -e "${YELLOW}Warning: Existing models found in $OLLAMA_MODELS_DIR${NC}"
    echo -e "${YELLOW}Existing models:${NC}"
    ollama list || echo -e "${YELLOW}  (Unable to list models)${NC}"
    echo ""
    echo -e "${YELLOW}These will be replaced by the backup.${NC}"
    echo ""
    read -p "Continue with restore? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo -e "${YELLOW}Restore cancelled.${NC}"
        exit 0
    fi

    # Remove existing models
    echo -e "${GREEN}Removing existing models...${NC}"
    rm -rf "$OLLAMA_MODELS_DIR"
fi

# Create Ollama directory if it doesn't exist
mkdir -p "$OLLAMA_DIR"

echo ""
echo -e "${GREEN}Extracting models from backup...${NC}"
echo -e "${YELLOW}This may take a while depending on the size of the backup...${NC}"

# Extract the backup
tar -xzf "$BACKUP_FILE" -C "$OLLAMA_DIR"

echo ""
echo -e "${GREEN}✓ Models restored successfully!${NC}"
echo ""
echo -e "${GREEN}Restored models:${NC}"
ollama list

echo ""
echo -e "${GREEN}You can now use these models with Open WebUI.${NC}"
echo -e "${GREEN}Start the service with: ${YELLOW}./start.sh${NC}"
echo ""
