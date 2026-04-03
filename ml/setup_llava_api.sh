#!/bin/bash
# Setup script for the LLaVA Species Identification API
# Run on the server: 186.3.241.59
#
# Prerequisites: Ollama v0.19.0 installed, llava:7b model pulled
#   ollama pull llava:7b

set -e

echo "=== Installing Python dependencies ==="
pip3 install fastapi uvicorn httpx python-multipart

echo "=== Pulling llava:7b model (if not already present) ==="
ollama pull llava:7b || echo "WARNING: Could not pull model. Ensure Ollama is running."

echo "=== Starting LLaVA API server on port 8089 ==="
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
nohup uvicorn llava_api_server:app --host 0.0.0.0 --port 8089 \
  --app-dir "$SCRIPT_DIR" > "$SCRIPT_DIR/llava_api.log" 2>&1 &

echo "Server PID: $!"
echo "Log file: $SCRIPT_DIR/llava_api.log"
echo ""
echo "Test with:"
echo "  curl http://localhost:8089/health"
echo "  curl -X POST http://localhost:8089/identify -F 'image=@test_photo.jpg'"
