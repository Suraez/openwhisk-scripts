#!/bin/bash

# Check if image name is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <image_name>"
  exit 1
fi

IMAGE_NAME=$1

# Get the image ID for the provided image name
IMAGE_ID=$(docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | grep "$IMAGE_NAME" | awk '{print $2}')

if [ -z "$IMAGE_ID" ]; then
  echo "Image '$IMAGE_NAME' not found."
  exit 1
fi

# Get the list of layer IDs associated with this image
LAYER_IDS=$(docker inspect --format='{{.RootFS.Layers}}' "$IMAGE_ID" | tr -d '[]' | tr ' ' '\n' | sed 's/^sha256://')

# Base directory for Docker overlay2 layer metadata
LAYERDB_DIR="/var/lib/docker/image/overlay2/layerdb/sha256"

# Loop through each layer ID and find the corresponding overlay2 directory
echo "Directories for image '$IMAGE_NAME' with ID '$IMAGE_ID':"
for LAYER_ID in $LAYER_IDS; do
  # Find the cache-id (actual overlay2 directory) for each layer
  CACHE_ID_FILE="$LAYERDB_DIR/$LAYER_ID/cache-id"
  if [ -f "$CACHE_ID_FILE" ]; then
    CACHE_ID=$(cat "$CACHE_ID_FILE")
    echo "/var/lib/docker/overlay2/$CACHE_ID"
  else
    echo "Layer $LAYER_ID: cache-id not found (possibly removed by Docker)."
  fi
done