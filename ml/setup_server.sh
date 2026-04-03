#!/bin/bash
# =============================================================================
# Setup PyTorch training environment on the remote server
# Server: erik@186.3.241.59:33 (10 CPU, 61GB RAM, no GPU)
#
# Usage:
#   sshpass -p 'Sys4dm1n1' ssh -p 33 erik@186.3.241.59 'bash -s' < ml/setup_server.sh
#   OR copy to server and run: bash setup_server.sh
# =============================================================================
set -e

echo "============================================"
echo "Galapagos Classifier - Server Setup"
echo "============================================"
echo "Date: $(date)"
echo "Host: $(hostname)"
echo "Python: $(python3 --version 2>&1)"
echo ""

# Create working directory
WORKDIR="$HOME/galapagos_training"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
echo "Working directory: $WORKDIR"

# Check Python version
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "Python version: $PYTHON_VERSION"

# Ensure pip is available
if ! command -v pip3 &>/dev/null; then
    echo "Installing pip..."
    sudo apt-get update && sudo apt-get install -y python3-pip python3-venv
fi

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi
source venv/bin/activate
echo "Virtual environment activated: $(which python3)"

# Upgrade pip
pip install --upgrade pip

# Install PyTorch CPU-only (saves ~1GB vs full CUDA build)
echo ""
echo "Installing PyTorch (CPU-only)..."
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Install core dependencies
echo ""
echo "Installing dependencies..."
pip install Pillow requests tqdm

# Install ONNX for model export
echo ""
echo "Installing ONNX..."
pip install onnx onnxruntime

# Try to install ai_edge_torch (Google's PyTorch -> TFLite converter)
echo ""
echo "Installing ai-edge-torch (optional, for direct TFLite export)..."
pip install ai-edge-torch 2>/dev/null || {
    echo "WARNING: ai-edge-torch failed to install."
    echo "  TFLite export will use ONNX intermediate format instead."
    echo "  You can convert ONNX to TFLite manually with onnx2tf:"
    echo "    pip install onnx2tf tensorflow"
}

# Verify installation
echo ""
echo "============================================"
echo "Verifying installation..."
echo "============================================"
python3 -c "
import torch
import torchvision
print(f'PyTorch: {torch.__version__}')
print(f'TorchVision: {torchvision.__version__}')
print(f'CPU threads: {torch.get_num_threads()}')
print(f'Cores available: {torch.get_num_interop_threads()}')

try:
    import onnx
    print(f'ONNX: {onnx.__version__}')
except ImportError:
    print('ONNX: not installed')

try:
    import ai_edge_torch
    print(f'ai_edge_torch: available')
except ImportError:
    print('ai_edge_torch: not available (will use ONNX export)')

import os
print(f'Disk free: {os.statvfs(\".\").f_frsize * os.statvfs(\".\").f_bavail / 1e9:.1f} GB')
print(f'Memory: {os.sysconf(\"SC_PAGE_SIZE\") * os.sysconf(\"SC_PHYS_PAGES\") / 1e9:.1f} GB')
"

# Set optimal CPU threading for training
echo ""
echo "CPU optimization tips for training:"
echo "  export OMP_NUM_THREADS=10"
echo "  export MKL_NUM_THREADS=10"
echo "  export TORCH_NUM_THREADS=10"

echo ""
echo "============================================"
echo "Setup complete!"
echo "============================================"
echo "Next steps:"
echo "  1. Copy train_server.py and species_list.json to $WORKDIR/"
echo "  2. Run: cd $WORKDIR && source venv/bin/activate"
echo "  3. Run: python3 train_server.py --species species_list.json --output output/"
echo ""
