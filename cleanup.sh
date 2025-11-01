#!/bin/bash

# Cleanup Open WebUI installation (keeps Ollama models)
# This removes: virtual environment, data, logs, and configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Open WebUI Cleanup${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${YELLOW}This will remove:${NC}"
echo -e "${YELLOW}  - Virtual environment (venv/)${NC}"
echo -e "${YELLOW}  - Data directory (data/)${NC}"
echo -e "${YELLOW}  - Configuration file (.env)${NC}"
echo -e "${YELLOW}  - Log files (*.log, *.pid)${NC}"
echo ""
echo -e "${GREEN}This will NOT remove:${NC}"
echo -e "${GREEN}  - Ollama models${NC}"
echo -e "${GREEN}  - System dependencies (Python, Ollama, etc.)${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Cleanup cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Starting cleanup...${NC}"

# Stop services first
if [ -f "stop.sh" ]; then
    echo -e "${GREEN}Stopping services...${NC}"
    bash stop.sh
fi

# Remove virtual environment
if [ -d "venv" ]; then
    echo -e "${GREEN}Removing virtual environment...${NC}"
    rm -rf venv
    echo -e "${GREEN}✓ Virtual environment removed${NC}"
fi

# Remove data directory
if [ -d "data" ]; then
    echo -e "${GREEN}Removing data directory...${NC}"
    rm -rf data
    echo -e "${GREEN}✓ Data directory removed${NC}"
fi

# Remove .env file
if [ -f ".env" ]; then
    echo -e "${GREEN}Removing configuration file...${NC}"
    rm -f .env
    echo -e "${GREEN}✓ Configuration file removed${NC}"
fi

# Remove log files
echo -e "${GREEN}Removing log files...${NC}"
rm -f *.log *.pid
echo -e "${GREEN}✓ Log files removed${NC}"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Cleanup Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${GREEN}To reinstall Open WebUI, run: ${YELLOW}./install.sh${NC}"
echo ""
