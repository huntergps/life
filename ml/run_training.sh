#!/bin/bash
# =============================================================================
# Run Galapagos species classifier training on the remote server
#
# This script is meant to run on the server in a tmux/screen session
# so it survives SSH disconnections.
#
# Usage (from local machine):
#   # 1. Copy files to server:
#   sshpass -p 'Sys4dm1n1' scp -P 33 ml/train_server.py ml/species_list.json \
#     erik@186.3.241.59:~/galapagos_training/
#
#   # 2. Copy this script:
#   sshpass -p 'Sys4dm1n1' scp -P 33 ml/run_training.sh \
#     erik@186.3.241.59:~/galapagos_training/
#
#   # 3. SSH in and run in tmux:
#   sshpass -p 'Sys4dm1n1' ssh -p 33 erik@186.3.241.59
#   tmux new -s training
#   cd ~/galapagos_training && bash run_training.sh
#   # Detach: Ctrl+B, D
#   # Reattach: tmux attach -t training
# =============================================================================
set -e

WORKDIR="$HOME/galapagos_training"
cd "$WORKDIR"

# Activate virtual environment
source venv/bin/activate

# Optimize CPU threading (server has 10 cores)
export OMP_NUM_THREADS=10
export MKL_NUM_THREADS=10
export TORCH_NUM_THREADS=10

# Create timestamped output directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="output_${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

echo "============================================"
echo "Galapagos Species Classifier Training"
echo "============================================"
echo "Date:       $(date)"
echo "Output:     $WORKDIR/$OUTPUT_DIR"
echo "Species:    species_list.json"
echo "============================================"
echo ""

# Run training with logging
python3 train_server.py \
    --species species_list.json \
    --output "$OUTPUT_DIR" \
    --images-per-species 100 \
    --min-images 10 \
    --epochs 30 \
    --batch-size 32 \
    --workers 8 \
    --lr 0.001 \
    --image-size 224 \
    2>&1 | tee "$OUTPUT_DIR/training.log"

echo ""
echo "============================================"
echo "Training finished at $(date)"
echo "Output: $WORKDIR/$OUTPUT_DIR"
echo "============================================"
echo ""
echo "Files produced:"
ls -lh "$OUTPUT_DIR/"
echo ""
echo "To copy results back to local machine:"
echo "  sshpass -p 'Sys4dm1n1' scp -P 33 -r erik@186.3.241.59:~/galapagos_training/$OUTPUT_DIR/ ml/output/"
