#!/bin/bash
# =============================================================================
# Deploy training pipeline to the remote server (run from local machine)
#
# Usage (from project root):
#   bash ml/deploy_to_server.sh
# =============================================================================
set -e

SERVER="erik@186.3.241.59"
PORT=33
PASS="Sys4dm1n1"
REMOTE_DIR="/home/erik/galapagos_training"
SSH="sshpass -p '$PASS' ssh -p $PORT -o StrictHostKeyChecking=no $SERVER"
SCP="sshpass -p '$PASS' scp -P $PORT -o StrictHostKeyChecking=no"

echo "============================================"
echo "Deploying to $SERVER:$PORT"
echo "============================================"

# Step 1: Create remote directory
echo "[1/4] Creating remote directory..."
eval $SSH "mkdir -p $REMOTE_DIR"

# Step 2: Copy training files
echo "[2/4] Copying training files..."
eval $SCP ml/train_server.py "$SERVER:$REMOTE_DIR/"
eval $SCP ml/species_list.json "$SERVER:$REMOTE_DIR/"
eval $SCP ml/setup_server.sh "$SERVER:$REMOTE_DIR/"
eval $SCP ml/run_training.sh "$SERVER:$REMOTE_DIR/"

# Step 3: Run setup (install dependencies)
echo "[3/4] Running setup on server..."
eval $SSH "cd $REMOTE_DIR && bash setup_server.sh"

echo ""
echo "============================================"
echo "Deployment complete!"
echo "============================================"
echo ""
echo "Next steps (SSH into the server):"
echo "  sshpass -p '$PASS' ssh -p $PORT $SERVER"
echo "  tmux new -s training"
echo "  cd $REMOTE_DIR && bash run_training.sh"
echo ""
echo "Or run training directly (will disconnect if SSH drops):"
echo "  eval \$SSH 'cd $REMOTE_DIR && bash run_training.sh'"
echo ""
