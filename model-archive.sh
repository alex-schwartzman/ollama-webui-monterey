#!/bin/bash

# Archive a specific Ollama model to external storage
# This allows selective offloading of bulky models
# Usage: ./model-archive.sh <model-name> <destination-path>

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Ollama Model Archiver${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

OLLAMA_MODELS_DIR="$HOME/.ollama/models"

# Check if models directory exists
if [ ! -d "$OLLAMA_MODELS_DIR" ]; then
    echo -e "${RED}Error: Ollama models directory not found at $OLLAMA_MODELS_DIR${NC}"
    exit 1
fi

# Show available models
echo -e "${GREEN}Available models:${NC}"
echo ""
ollama list
echo ""

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo ""
    echo -e "${YELLOW}Usage: ./model-archive.sh <model-name> <destination-path>${NC}"
    echo ""
    echo -e "${GREEN}Examples:${NC}"
    echo "  ./model-archive.sh llama3.2 /Volumes/ExternalDrive/model-archives"
    echo "  ./model-archive.sh mistral:7b ./model-archives"
    echo ""
    exit 1
fi

MODEL_NAME="$1"
ARCHIVE_DIR="$2"

# Verify model exists
if ! ollama list | grep -q "^$MODEL_NAME"; then
    echo -e "${RED}Error: Model '$MODEL_NAME' not found${NC}"
    echo -e "${YELLOW}Make sure to use the exact name from 'ollama list'${NC}"
    exit 1
fi

# Create archive directory if needed
mkdir -p "$ARCHIVE_DIR"

# Convert model name to manifest path
# Replace : with / (e.g., "gemma3:270m" -> "gemma3/270m")
# Add /latest if no tag (e.g., "llama3.2" -> "llama3.2/latest")
if [[ "$MODEL_NAME" == *:* ]]; then
    MANIFEST_PATH="${MODEL_NAME/://}"
else
    MANIFEST_PATH="$MODEL_NAME/latest"
fi

# Check if it's in library namespace or has its own namespace
if [[ "$MODEL_NAME" == */* ]]; then
    # Has namespace (e.g., "jobautomation/OpenEuroLLM-Czech")
    MODEL_MANIFEST="$OLLAMA_MODELS_DIR/manifests/registry.ollama.ai/$MANIFEST_PATH"
else
    # Default library namespace
    MODEL_MANIFEST="$OLLAMA_MODELS_DIR/manifests/registry.ollama.ai/library/$MANIFEST_PATH"
fi

if [ ! -f "$MODEL_MANIFEST" ]; then
    echo -e "${RED}Error: Could not find model manifest at $MODEL_MANIFEST${NC}"
    exit 1
fi

# Get total size from manifest early to show user
if command -v jq &> /dev/null; then
    TOTAL_SIZE=$(cat "$MODEL_MANIFEST" | jq '[.layers[].size] | add' 2>/dev/null || echo 0)
else
    # Fallback: parse sizes without jq
    TOTAL_SIZE=$(grep -o '"size"[[:space:]]*:[[:space:]]*[0-9]*' "$MODEL_MANIFEST" | awk -F: '{sum += $2} END {print sum}')
fi

TOTAL_SIZE_MB=$((TOTAL_SIZE / 1024 / 1024))
TOTAL_SIZE_GB=$((TOTAL_SIZE / 1024 / 1024 / 1024))

# Now show info and prompt user
SAFE_MODEL_NAME=$(echo "$MODEL_NAME" | sed 's/[:/]/-/g')
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_FILE="$ARCHIVE_DIR/${SAFE_MODEL_NAME}_${TIMESTAMP}.tar.gz"

echo ""
echo -e "${BLUE}Model: ${YELLOW}$MODEL_NAME${NC}"
echo -e "${BLUE}Archive to: ${YELLOW}$ARCHIVE_FILE${NC}"

# Show size with warning for large models
if [ $TOTAL_SIZE_GB -gt 0 ]; then
    echo -e "${BLUE}Model size: ${YELLOW}${TOTAL_SIZE_GB} GB${NC}"
    if [ $TOTAL_SIZE_GB -gt 10 ]; then
        echo -e "${RED}⚠ Large model - archiving will take a considerable amount of time!${NC}"
    fi
else
    echo -e "${BLUE}Model size: ${YELLOW}${TOTAL_SIZE_MB} MB${NC}"
fi
echo ""

# Show model info
echo -e "${GREEN}Model information:${NC}"
ollama show "$MODEL_NAME" 2>/dev/null | head -20 || echo -e "${YELLOW}Could not retrieve model info${NC}"
echo ""

read -p "Archive this model? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Archive cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Creating archive...${NC}"

# Get blob references from manifest
echo -e "${GREEN}Collecting model files...${NC}"
if command -v jq &> /dev/null; then
    # Get config blob and layer blobs
    CONFIG_BLOB=$(cat "$MODEL_MANIFEST" | jq -r '.config.digest' 2>/dev/null | sed 's/sha256://')
    LAYER_BLOBS=$(cat "$MODEL_MANIFEST" | jq -r '.layers[].digest' 2>/dev/null | sed 's/sha256://')
    BLOBS=$(echo -e "$CONFIG_BLOB\n$LAYER_BLOBS")
else
    # Fallback without jq - get all sha256 references
    BLOBS=$(grep -o 'sha256:[a-f0-9]*' "$MODEL_MANIFEST" | sed 's/sha256://')
fi

# Build list of files to archive (relative to OLLAMA_MODELS_DIR)
FILES_TO_ARCHIVE=()

# Add manifest (relative path)
RELATIVE_MANIFEST=$(echo "$MODEL_MANIFEST" | sed "s|$OLLAMA_MODELS_DIR/||")
FILES_TO_ARCHIVE+=("$RELATIVE_MANIFEST")

# Add blobs (relative paths)
for blob in $BLOBS; do
    BLOB_FILE="blobs/sha256-$blob"
    if [ -f "$OLLAMA_MODELS_DIR/$BLOB_FILE" ]; then
        FILES_TO_ARCHIVE+=("$BLOB_FILE")
    else
        echo -e "${YELLOW}Warning: Blob not found: $blob${NC}"
    fi
done

echo -e "${GREEN}Archiving ${#FILES_TO_ARCHIVE[@]} files (${TOTAL_SIZE_MB} MB)...${NC}"

# Determine compression tool (pigz for parallel, gzip for fallback)
if command -v pigz &> /dev/null; then
    GZIP_CMD="pigz -p 16"
    echo -e "${GREEN}Using parallel compression (pigz with up to 16 cores)${NC}"
else
    GZIP_CMD="gzip"
    if [ $TOTAL_SIZE_GB -gt 5 ]; then
        echo -e "${YELLOW}Consider installing pigz for faster compression on large models${NC}"
    fi
fi

# Create archive directly - will untar straight to ~/.ollama/models during restore
# Use pv for progress if available
if command -v pv &> /dev/null; then
    tar -c -C "$OLLAMA_MODELS_DIR" "${FILES_TO_ARCHIVE[@]}" | pv -s "$TOTAL_SIZE" | $GZIP_CMD > "$ARCHIVE_FILE"
else
    if [ "$GZIP_CMD" = "pigz" ]; then
        tar -c -C "$OLLAMA_MODELS_DIR" "${FILES_TO_ARCHIVE[@]}" | pigz > "$ARCHIVE_FILE"
    else
        echo -e "${YELLOW}Install pv for a progress bar${NC}"
        tar -czf "$ARCHIVE_FILE" -C "$OLLAMA_MODELS_DIR" "${FILES_TO_ARCHIVE[@]}"
    fi
fi

echo -e "${GREEN}✓ Archive created successfully${NC}"

# Show archive size
ARCHIVE_SIZE=$(du -sh "$ARCHIVE_FILE" | cut -f1)
echo -e "${GREEN}Archive size: ${YELLOW}$ARCHIVE_SIZE${NC}"
echo ""

# Ask to remove local model
echo -e "${YELLOW}Remove local model to free up space?${NC}"
read -p "Remove '$MODEL_NAME'? (yes/no): " REMOVE_CONFIRM

if [ "$REMOVE_CONFIRM" = "yes" ]; then
    echo -e "${GREEN}Removing local model...${NC}"
    ollama rm "$MODEL_NAME"
    echo -e "${GREEN}✓ Model removed from local storage${NC}"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Archive Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${GREEN}Archive: ${YELLOW}$ARCHIVE_FILE${NC}"
echo -e "${GREEN}To restore: ${YELLOW}./model-unarchive.sh \"$ARCHIVE_FILE\"${NC}"
echo ""
