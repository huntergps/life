#!/usr/bin/env python3
"""
Train MobileNetV3-Small classifier for Galapagos species.
Runs on CPU (no GPU required). Downloads images from iNaturalist.

Usage:
  python3 train_server.py --species species_list.json --output output/ [options]

Options:
  --images-per-species  Max images to download per species (default: 100)
  --epochs              Training epochs (default: 30)
  --batch-size          Batch size for training (default: 32)
  --workers             DataLoader workers (default: 8)
  --lr                  Initial learning rate (default: 0.001)
  --resume              Resume from checkpoint
  --skip-download       Skip image download, use existing images
  --min-images          Minimum images required to include a species (default: 10)
  --image-size          Input image size (default: 224)

Server target: 10 CPU cores, 61GB RAM, no GPU.
"""

import argparse
import json
import os
import sys
import time
import urllib.request
import urllib.parse
import urllib.error
import hashlib
import logging
import shutil
from datetime import datetime
from pathlib import Path
from io import BytesIO

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset, WeightedRandomSampler
from torchvision import transforms, models
from PIL import Image

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("train")


# ---------------------------------------------------------------------------
# iNaturalist download helpers
# ---------------------------------------------------------------------------
INAT_API = "https://api.inaturalist.org/v1"
# Galapagos place_id in iNaturalist
GALAPAGOS_PLACE_ID = 7161

# User-Agent to be polite to iNaturalist API
HEADERS = {"User-Agent": "GalapagosWildlifeApp/1.0 (training pipeline)"}


def _api_get(url: str, retries: int = 3) -> dict:
    """GET request to iNaturalist API with retries and rate limiting."""
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = json.loads(resp.read())
            return data
        except (urllib.error.URLError, urllib.error.HTTPError, OSError) as e:
            if attempt < retries - 1:
                wait = 2 ** attempt
                log.warning(f"  API error ({e}), retry in {wait}s...")
                time.sleep(wait)
            else:
                log.error(f"  API failed after {retries} attempts: {e}")
                return {}


def resolve_taxon_id(scientific_name: str) -> int | None:
    """Look up iNaturalist taxon_id by scientific name."""
    params = urllib.parse.urlencode({"q": scientific_name, "per_page": 5})
    url = f"{INAT_API}/taxa?{params}"
    data = _api_get(url)
    if not data:
        return None
    for taxon in data.get("results", []):
        # Exact or close match on name
        if taxon.get("name", "").lower() == scientific_name.lower():
            return taxon["id"]
    # Fallback: return first result if any
    results = data.get("results", [])
    if results:
        return results[0]["id"]
    return None


def download_species_images(
    taxon_id: int | None,
    scientific_name: str,
    output_dir: Path,
    max_images: int = 100,
) -> int:
    """Download research-grade observation photos from iNaturalist.

    Strategy:
      1. Search Galapagos first (place_id=7161) for local observations
      2. Fill remaining with global observations
      3. If no taxon_id, try to resolve it from scientific name
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    existing = list(output_dir.glob("*.jpg"))
    if len(existing) >= max_images:
        return len(existing)

    # Resolve taxon_id if missing
    if taxon_id is None:
        taxon_id = resolve_taxon_id(scientific_name)
        if taxon_id:
            log.info(f"  Resolved taxon_id={taxon_id} for {scientific_name}")
        else:
            log.warning(f"  Could not resolve taxon_id for {scientific_name}")
            return len(existing)

    # Collect photo URLs: Galapagos first, then global
    all_urls = []
    seen_urls = set()

    for place_id in [GALAPAGOS_PLACE_ID, None]:
        if len(all_urls) >= max_images * 3:
            break
        page = 1
        while len(all_urls) < max_images * 3:
            params = {
                "taxon_id": taxon_id,
                "quality_grade": "research",
                "photos": "true",
                "per_page": 200,
                "page": page,
                "order_by": "votes",
            }
            if place_id:
                params["place_id"] = place_id
            url = f"{INAT_API}/observations?{urllib.parse.urlencode(params)}"
            data = _api_get(url)
            if not data:
                break
            results = data.get("results", [])
            if not results:
                break
            for obs in results:
                for photo in obs.get("photos", []):
                    photo_url = photo.get("url", "").replace("square", "medium")
                    if photo_url and photo_url not in seen_urls:
                        seen_urls.add(photo_url)
                        all_urls.append(photo_url)
            if len(results) < 200:
                break
            page += 1
            time.sleep(0.5)  # Rate limit

    # Download images
    downloaded = len(existing)
    errors = 0
    for photo_url in all_urls:
        if downloaded >= max_images:
            break
        fname = output_dir / f"{downloaded:04d}.jpg"
        if fname.exists():
            downloaded += 1
            continue
        try:
            req = urllib.request.Request(photo_url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=15) as resp:
                img_data = resp.read()
            # Validate it's a real image
            img = Image.open(BytesIO(img_data))
            img.verify()
            fname.write_bytes(img_data)
            downloaded += 1
        except Exception:
            errors += 1
            if errors > 20:
                break

    return downloaded


# ---------------------------------------------------------------------------
# Dataset
# ---------------------------------------------------------------------------
class GalapagosDataset(Dataset):
    """Image dataset from directory structure: images_dir/species_key/*.jpg"""

    def __init__(self, samples: list[tuple[str, int]], transform=None):
        """
        Args:
            samples: list of (image_path, class_index) tuples
            transform: torchvision transforms
        """
        self.samples = samples
        self.transform = transform

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        path, label = self.samples[idx]
        try:
            img = Image.open(path).convert("RGB")
        except Exception:
            # Return a black image on read error
            img = Image.new("RGB", (224, 224), (0, 0, 0))
        if self.transform:
            img = self.transform(img)
        return img, label


# ---------------------------------------------------------------------------
# Model
# ---------------------------------------------------------------------------
def create_model(num_classes: int, pretrained: bool = True) -> nn.Module:
    """Create MobileNetV3-Small with custom classifier head."""
    weights = models.MobileNet_V3_Small_Weights.DEFAULT if pretrained else None
    model = models.mobilenet_v3_small(weights=weights)
    # Replace classifier: last layer is Linear(1024, 1000)
    in_features = model.classifier[-1].in_features
    model.classifier[-1] = nn.Linear(in_features, num_classes)
    return model


# ---------------------------------------------------------------------------
# Training
# ---------------------------------------------------------------------------
def train_one_epoch(model, loader, criterion, optimizer, device, epoch):
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0
    batch_count = len(loader)

    for i, (images, labels) in enumerate(loader):
        images, labels = images.to(device), labels.to(device)
        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

        running_loss += loss.item()
        _, predicted = outputs.max(1)
        total += labels.size(0)
        correct += predicted.eq(labels).sum().item()

        if (i + 1) % 50 == 0 or (i + 1) == batch_count:
            acc = 100.0 * correct / total
            avg_loss = running_loss / (i + 1)
            log.info(
                f"  Epoch {epoch} [{i+1}/{batch_count}] "
                f"loss={avg_loss:.4f} acc={acc:.1f}%"
            )

    return running_loss / batch_count, 100.0 * correct / total


def validate(model, loader, criterion, device):
    model.eval()
    running_loss = 0.0
    correct = 0
    total = 0

    with torch.no_grad():
        for images, labels in loader:
            images, labels = images.to(device), labels.to(device)
            outputs = model(images)
            loss = criterion(outputs, labels)
            running_loss += loss.item()
            _, predicted = outputs.max(1)
            total += labels.size(0)
            correct += predicted.eq(labels).sum().item()

    avg_loss = running_loss / len(loader) if len(loader) > 0 else 0
    acc = 100.0 * correct / total if total > 0 else 0
    return avg_loss, acc


# ---------------------------------------------------------------------------
# TFLite export
# ---------------------------------------------------------------------------
def export_to_tflite(model, output_path: Path, input_size: int = 224):
    """Export PyTorch model to TFLite via ONNX intermediate format.

    Pipeline: PyTorch -> ONNX -> TFLite (using ai_edge_torch or onnx2tf)
    """
    model.eval()
    model_cpu = model.cpu()
    dummy_input = torch.randn(1, 3, input_size, input_size)

    # Method 1: Try ai_edge_torch (Google's official converter)
    try:
        import ai_edge_torch

        log.info("Exporting with ai_edge_torch...")
        edge_model = ai_edge_torch.convert(model_cpu, (dummy_input,))
        tflite_path = output_path / "galapagos_classifier.tflite"
        edge_model.export(str(tflite_path))
        log.info(f"TFLite saved: {tflite_path} ({tflite_path.stat().st_size / 1e6:.1f} MB)")
        return True
    except ImportError:
        log.info("ai_edge_torch not available, trying ONNX path...")
    except Exception as e:
        log.warning(f"ai_edge_torch failed ({e}), trying ONNX path...")

    # Method 2: Export to ONNX (can be converted to TFLite separately)
    try:
        onnx_path = output_path / "galapagos_classifier.onnx"
        log.info(f"Exporting to ONNX: {onnx_path}")
        torch.onnx.export(
            model_cpu,
            dummy_input,
            str(onnx_path),
            export_params=True,
            opset_version=13,
            do_constant_folding=True,
            input_names=["input"],
            output_names=["output"],
            dynamic_axes={"input": {0: "batch"}, "output": {0: "batch"}},
        )
        size_mb = onnx_path.stat().st_size / 1e6
        log.info(f"ONNX saved: {onnx_path} ({size_mb:.1f} MB)")

        # Try quantized ONNX
        try:
            from onnxruntime.quantization import quantize_dynamic, QuantType

            onnx_quant_path = output_path / "galapagos_classifier_quant.onnx"
            quantize_dynamic(
                str(onnx_path),
                str(onnx_quant_path),
                weight_type=QuantType.QUInt8,
            )
            qsize = onnx_quant_path.stat().st_size / 1e6
            log.info(f"Quantized ONNX saved: {onnx_quant_path} ({qsize:.1f} MB)")
        except ImportError:
            log.info("onnxruntime not available for quantization")

        # Try onnx2tf for TFLite conversion
        try:
            import subprocess

            tflite_path = output_path / "galapagos_classifier.tflite"
            log.info("Converting ONNX -> TFLite with onnx2tf...")
            subprocess.run(
                [
                    "onnx2tf",
                    "-i", str(onnx_path),
                    "-o", str(output_path / "tf_model"),
                    "-oiqt",  # INT8 quantization
                ],
                check=True,
                capture_output=True,
                text=True,
            )
            # onnx2tf puts the tflite in tf_model/
            tf_model_dir = output_path / "tf_model"
            for f in tf_model_dir.glob("*.tflite"):
                shutil.copy(f, tflite_path)
                break
            if tflite_path.exists():
                log.info(f"TFLite saved: {tflite_path} ({tflite_path.stat().st_size / 1e6:.1f} MB)")
                return True
        except (ImportError, FileNotFoundError, subprocess.CalledProcessError) as e:
            log.info(f"onnx2tf not available ({e})")

        log.info(
            "ONNX model saved. To convert to TFLite manually:\n"
            "  pip install onnx2tf && onnx2tf -i galapagos_classifier.onnx -o tf_out -oiqt\n"
            "  OR use https://github.com/google-ai-edge/ai-edge-torch"
        )
        return True

    except Exception as e:
        log.error(f"ONNX export failed: {e}")

    # Method 3: Save TorchScript as fallback
    try:
        script_path = output_path / "galapagos_classifier.pt"
        scripted = torch.jit.trace(model_cpu, dummy_input)
        scripted.save(str(script_path))
        log.info(f"TorchScript saved: {script_path} ({script_path.stat().st_size / 1e6:.1f} MB)")
        return True
    except Exception as e:
        log.error(f"TorchScript export also failed: {e}")
        return False


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Train Galapagos species classifier")
    parser.add_argument("--species", required=True, help="Path to species_list.json")
    parser.add_argument("--output", default="output", help="Output directory")
    parser.add_argument("--images-dir", default=None, help="Image directory (default: output/images)")
    parser.add_argument("--images-per-species", type=int, default=100)
    parser.add_argument("--min-images", type=int, default=10, help="Min images to include species")
    parser.add_argument("--epochs", type=int, default=30)
    parser.add_argument("--batch-size", type=int, default=32)
    parser.add_argument("--workers", type=int, default=8)
    parser.add_argument("--lr", type=float, default=0.001)
    parser.add_argument("--image-size", type=int, default=224)
    parser.add_argument("--resume", type=str, default=None, help="Resume from checkpoint")
    parser.add_argument("--skip-download", action="store_true", help="Skip downloading images")
    parser.add_argument("--val-split", type=float, default=0.2, help="Validation split ratio")
    args = parser.parse_args()

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)
    images_dir = Path(args.images_dir) if args.images_dir else output_dir / "images"
    images_dir.mkdir(parents=True, exist_ok=True)

    # Load species list
    with open(args.species) as f:
        species_list = json.load(f)
    log.info(f"Loaded {len(species_list)} species from {args.species}")

    # -----------------------------------------------------------------------
    # Phase 1: Download images
    # -----------------------------------------------------------------------
    if not args.skip_download:
        log.info("=" * 60)
        log.info("PHASE 1: Downloading images from iNaturalist")
        log.info("=" * 60)
        for i, sp in enumerate(species_list):
            sp_key = f"{sp['id']:03d}_{sp['scientific_name'].replace(' ', '_')}"
            sp_dir = images_dir / sp_key
            existing = len(list(sp_dir.glob("*.jpg"))) if sp_dir.exists() else 0
            if existing >= args.images_per_species:
                log.info(
                    f"[{i+1}/{len(species_list)}] {sp['common_name_en']}: "
                    f"{existing} images (skip)"
                )
                continue
            log.info(
                f"[{i+1}/{len(species_list)}] Downloading {sp['common_name_en']} "
                f"({sp['scientific_name']})..."
            )
            count = download_species_images(
                taxon_id=sp.get("taxon_id"),
                scientific_name=sp["scientific_name"],
                output_dir=sp_dir,
                max_images=args.images_per_species,
            )
            log.info(f"  -> {count} images")
            time.sleep(0.3)  # Be nice to iNat API

    # -----------------------------------------------------------------------
    # Phase 2: Build dataset
    # -----------------------------------------------------------------------
    log.info("=" * 60)
    log.info("PHASE 2: Building dataset")
    log.info("=" * 60)

    # Scan image directories and filter by min_images
    class_dirs = []
    for sp in species_list:
        sp_key = f"{sp['id']:03d}_{sp['scientific_name'].replace(' ', '_')}"
        sp_dir = images_dir / sp_key
        if sp_dir.exists():
            imgs = list(sp_dir.glob("*.jpg"))
            if len(imgs) >= args.min_images:
                class_dirs.append((sp, sp_dir, imgs))

    if not class_dirs:
        log.error("No species have enough images. Aborting.")
        sys.exit(1)

    # Assign class indices (0-based, only for species with enough images)
    class_to_idx = {}
    idx_to_species = {}
    for idx, (sp, _, _) in enumerate(class_dirs):
        class_to_idx[sp["id"]] = idx
        idx_to_species[idx] = sp

    num_classes = len(class_dirs)
    log.info(f"Training with {num_classes} classes (min {args.min_images} images each)")

    # Build samples list and split train/val
    import random
    random.seed(42)

    train_samples = []
    val_samples = []
    class_counts = []

    for sp, sp_dir, imgs in class_dirs:
        idx = class_to_idx[sp["id"]]
        img_paths = [str(p) for p in imgs]
        random.shuffle(img_paths)
        split_point = max(1, int(len(img_paths) * (1 - args.val_split)))
        train_paths = img_paths[:split_point]
        val_paths = img_paths[split_point:]
        for p in train_paths:
            train_samples.append((p, idx))
        for p in val_paths:
            val_samples.append((p, idx))
        class_counts.append(len(train_paths))
        log.info(
            f"  [{idx:3d}] {sp['common_name_en']:<45} "
            f"train={len(train_paths):4d} val={len(val_paths):3d}"
        )

    log.info(f"Total: {len(train_samples)} train, {len(val_samples)} val samples")

    # Save labels.txt (ordered by class index)
    labels_path = output_dir / "labels.txt"
    with open(labels_path, "w") as f:
        for idx in range(num_classes):
            sp = idx_to_species[idx]
            f.write(f"{sp['common_name_en']}\n")
    log.info(f"Labels saved: {labels_path}")

    # Save detailed label mapping (includes DB id, scientific name, etc.)
    label_map_path = output_dir / "label_mapping.json"
    label_map = {}
    for idx in range(num_classes):
        sp = idx_to_species[idx]
        label_map[str(idx)] = {
            "db_id": sp["id"],
            "scientific_name": sp["scientific_name"],
            "common_name_en": sp["common_name_en"],
            "common_name_es": sp.get("common_name_es", ""),
        }
    with open(label_map_path, "w") as f:
        json.dump(label_map, f, indent=2, ensure_ascii=False)
    log.info(f"Label mapping saved: {label_map_path}")

    # -----------------------------------------------------------------------
    # Phase 3: Data loaders
    # -----------------------------------------------------------------------
    # Augmentation for training
    train_transform = transforms.Compose([
        transforms.RandomResizedCrop(args.image_size, scale=(0.7, 1.0)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(15),
        transforms.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.2, hue=0.05),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])
    val_transform = transforms.Compose([
        transforms.Resize(int(args.image_size * 1.15)),
        transforms.CenterCrop(args.image_size),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])

    train_dataset = GalapagosDataset(train_samples, transform=train_transform)
    val_dataset = GalapagosDataset(val_samples, transform=val_transform)

    # Weighted sampler for class imbalance
    sample_weights = []
    total_samples = sum(class_counts)
    class_weights = [total_samples / (num_classes * c) for c in class_counts]
    for _, label in train_samples:
        sample_weights.append(class_weights[label])
    sampler = WeightedRandomSampler(sample_weights, len(sample_weights))

    train_loader = DataLoader(
        train_dataset,
        batch_size=args.batch_size,
        sampler=sampler,
        num_workers=args.workers,
        pin_memory=True,
        drop_last=True,
    )
    val_loader = DataLoader(
        val_dataset,
        batch_size=args.batch_size,
        shuffle=False,
        num_workers=args.workers,
        pin_memory=True,
    )

    # -----------------------------------------------------------------------
    # Phase 4: Training
    # -----------------------------------------------------------------------
    log.info("=" * 60)
    log.info("PHASE 4: Training MobileNetV3-Small")
    log.info("=" * 60)

    device = torch.device("cpu")
    log.info(f"Device: {device}")
    log.info(f"Classes: {num_classes}, Epochs: {args.epochs}, LR: {args.lr}")
    log.info(f"Batch size: {args.batch_size}, Workers: {args.workers}")

    model = create_model(num_classes, pretrained=True)
    model = model.to(device)

    # Use label smoothing for better generalization
    criterion = nn.CrossEntropyLoss(label_smoothing=0.1)
    optimizer = optim.AdamW(model.parameters(), lr=args.lr, weight_decay=1e-4)
    scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=args.epochs)

    # Resume from checkpoint
    start_epoch = 1
    best_val_acc = 0.0
    if args.resume and Path(args.resume).exists():
        log.info(f"Resuming from {args.resume}")
        ckpt = torch.load(args.resume, map_location=device)
        model.load_state_dict(ckpt["model_state_dict"])
        optimizer.load_state_dict(ckpt["optimizer_state_dict"])
        start_epoch = ckpt.get("epoch", 0) + 1
        best_val_acc = ckpt.get("best_val_acc", 0.0)
        log.info(f"Resumed at epoch {start_epoch}, best_val_acc={best_val_acc:.1f}%")

    # Training loop
    checkpoint_dir = output_dir / "checkpoints"
    checkpoint_dir.mkdir(exist_ok=True)
    history = {"train_loss": [], "train_acc": [], "val_loss": [], "val_acc": []}

    for epoch in range(start_epoch, args.epochs + 1):
        epoch_start = time.time()
        log.info(f"\n--- Epoch {epoch}/{args.epochs} (lr={scheduler.get_last_lr()[0]:.6f}) ---")

        train_loss, train_acc = train_one_epoch(
            model, train_loader, criterion, optimizer, device, epoch
        )
        val_loss, val_acc = validate(model, val_loader, criterion, device)
        scheduler.step()

        elapsed = time.time() - epoch_start
        log.info(
            f"Epoch {epoch}: train_loss={train_loss:.4f} train_acc={train_acc:.1f}% "
            f"val_loss={val_loss:.4f} val_acc={val_acc:.1f}% "
            f"time={elapsed:.0f}s"
        )

        history["train_loss"].append(train_loss)
        history["train_acc"].append(train_acc)
        history["val_loss"].append(val_loss)
        history["val_acc"].append(val_acc)

        # Save checkpoint every 5 epochs
        if epoch % 5 == 0:
            ckpt_path = checkpoint_dir / f"checkpoint_epoch{epoch:03d}.pt"
            torch.save(
                {
                    "epoch": epoch,
                    "model_state_dict": model.state_dict(),
                    "optimizer_state_dict": optimizer.state_dict(),
                    "train_loss": train_loss,
                    "train_acc": train_acc,
                    "val_loss": val_loss,
                    "val_acc": val_acc,
                    "best_val_acc": best_val_acc,
                    "num_classes": num_classes,
                },
                ckpt_path,
            )
            log.info(f"Checkpoint saved: {ckpt_path}")

        # Save best model
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            best_path = output_dir / "best_model.pt"
            torch.save(
                {
                    "epoch": epoch,
                    "model_state_dict": model.state_dict(),
                    "num_classes": num_classes,
                    "val_acc": val_acc,
                },
                best_path,
            )
            log.info(f"New best model: val_acc={val_acc:.1f}% -> {best_path}")

    # Save training history
    with open(output_dir / "training_history.json", "w") as f:
        json.dump(history, f, indent=2)

    # -----------------------------------------------------------------------
    # Phase 5: Export
    # -----------------------------------------------------------------------
    log.info("=" * 60)
    log.info("PHASE 5: Exporting model")
    log.info("=" * 60)

    # Load best model for export
    best_ckpt = torch.load(output_dir / "best_model.pt", map_location=device)
    model.load_state_dict(best_ckpt["model_state_dict"])
    log.info(
        f"Loaded best model from epoch {best_ckpt['epoch']} "
        f"(val_acc={best_ckpt['val_acc']:.1f}%)"
    )

    export_to_tflite(model, output_dir, args.image_size)

    # -----------------------------------------------------------------------
    # Summary
    # -----------------------------------------------------------------------
    log.info("=" * 60)
    log.info("TRAINING COMPLETE")
    log.info("=" * 60)
    log.info(f"Classes: {num_classes}")
    log.info(f"Best val accuracy: {best_val_acc:.1f}%")
    log.info(f"Output directory: {output_dir}")
    log.info(f"Files:")
    for f in sorted(output_dir.iterdir()):
        if f.is_file():
            size = f.stat().st_size
            if size > 1e6:
                log.info(f"  {f.name} ({size/1e6:.1f} MB)")
            else:
                log.info(f"  {f.name} ({size/1e3:.0f} KB)")


if __name__ == "__main__":
    main()
