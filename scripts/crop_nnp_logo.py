#!/usr/bin/env python3
"""Crop NNP logo PNG to top half (light-on-white variant)."""
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    raise SystemExit("Pillow required: pip install Pillow")

ROOT = Path(__file__).resolve().parents[1]
path = ROOT / "site/www.geldofpoultry.com/assets/images/nnp/logo.png"
im = Image.open(path).convert("RGBA")
w, h = im.size
top = im.crop((0, 0, w, h // 2))
top.save(path, format="PNG", optimize=True)
print(f"Cropped {path.name}: {w}x{h} -> {w}x{h // 2}")
