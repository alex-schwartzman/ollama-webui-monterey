#!/bin/bash

# Restore a specific Ollama model from archive
# Usage: ./model-unarchive.sh <archive-file.tar.gz>

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Ollama Model Unarchiver${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

OLLAMA_MODELS_DIR="$HOME/.ollama/models"

# Check if archive file argument is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No archive file specified${NC}"
    echo ""
    echo -e "${YELLOW}Usage: ./model-unarchive.sh <archive-file.tar.gz>${NC}"
    echo ""
    echo -e "${GREEN}Available archives:${NC}"
    if [ -d "model-archives" ] && [ "$(ls -A model-archives/*.tar.gz 2>/dev/null)" ]; then
        ls -lh model-archives/*.tar.gz
    else
        echo -e "${YELLOW}  No archives found in model-archives/ directory${NC}"
    fi
    echo ""
    exit 1
fi

ARCHIVE_FILE="$1"

# Check if archive file exists
if [ ! -f "$ARCHIVE_FILE" ]; then
    echo -e "${RED}Error: Archive file not found: $ARCHIVE_FILE${NC}"
    exit 1
fi

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Error: Ollama is not installed${NC}"
    exit 1
fi

# Show archive info
ARCHIVE_SIZE_BYTES=$(stat -f%z "$ARCHIVE_FILE" 2>/dev/null || stat -c%s "$ARCHIVE_FILE" 2>/dev/null)
ARCHIVE_SIZE_MB=$((ARCHIVE_SIZE_BYTES / 1024 / 1024))
ARCHIVE_SIZE_GB=$((ARCHIVE_SIZE_BYTES / 1024 / 1024 / 1024))

echo -e "${GREEN}Archive file: ${YELLOW}$ARCHIVE_FILE${NC}"

if [ $ARCHIVE_SIZE_GB -gt 0 ]; then
    echo -e "${GREEN}Archive size: ${YELLOW}${ARCHIVE_SIZE_GB} GB${NC}"
    if [ $ARCHIVE_SIZE_GB -gt 10 ]; then
        echo -e "${RED}⚠ Large archive - extraction will take a considerable amount of time!${NC}"
    fi
else
    echo -e "${GREEN}Archive size: ${YELLOW}${ARCHIVE_SIZE_MB} MB${NC}"
fi
echo ""

read -p "Restore this model? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Restore cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Extracting archive (${ARCHIVE_SIZE_MB} MB)...${NC}"

# Create models directory if it doesn't exist
mkdir -p "$OLLAMA_MODELS_DIR"

# Extract archive directly to ~/.ollama/models
# Use pv for progress if available
if command -v pv &> /dev/null; then
    pv "$ARCHIVE_FILE" | tar -xz -C "$OLLAMA_MODELS_DIR"
else
    echo -e "${YELLOW}Install pv for a progress bar${NC}"
    tar -xzf "$ARCHIVE_FILE" -C "$OLLAMA_MODELS_DIR"
fi

echo -e "${GREEN}✓ Model files restored${NC}"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Unarchive Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

echo -e "${GREEN}Restored models:${NC}"
ollama list

echo ""
echo -e "${GREEN}You can now use the restored model with Open WebUI.${NC}"
echo -e "${GREEN}Start the service with: ${YELLOW}./start.sh${NC}"
echo ""
