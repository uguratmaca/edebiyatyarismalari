"""Prepare a competition announcement image for publishing.

Usage:
    python scripts/process_image.py <input> <output.webp> [--text "edebiyatyarismalari.com"]

Stamps a small semi-transparent watermark badge in the bottom-right corner
and saves as WebP. Does NOT force-crop to 1200x630 by default: `.hero-img`
in css/theme.css already applies `aspect-ratio: 1200/630; object-fit: contain`,
so any source aspect ratio (portrait Instagram posts included) displays fine
on the page as-is. Pass --resize if a hard crop to 1200x630 is actually
wanted for a specific image. Run with the venv-free system Python (Pillow
must be installed).
"""

import argparse
import os
import sys

from PIL import Image, ImageDraw, ImageFont

TARGET_SIZE = (1200, 630)
FONT_CANDIDATES = [
    r"C:\Windows\Fonts\arialbd.ttf",
    r"C:\Windows\Fonts\calibrib.ttf",
]


def cover_resize_crop(im, target_w, target_h):
    src_w, src_h = im.size
    src_ratio = src_w / src_h
    target_ratio = target_w / target_h

    if src_ratio > target_ratio:
        new_h = target_h
        new_w = int(new_h * src_ratio)
    else:
        new_w = target_w
        new_h = int(new_w / src_ratio)

    im = im.resize((new_w, new_h), Image.LANCZOS)

    left = (new_w - target_w) // 2
    top = (new_h - target_h) // 2
    return im.crop((left, top, left + target_w, top + target_h))


def load_font(size):
    for path in FONT_CANDIDATES:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def add_watermark(im, text, margin=20, font_size=26):
    im = im.convert("RGBA")
    overlay = Image.new("RGBA", im.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    font = load_font(font_size)

    pad_x, pad_y = 14, 8
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w, text_h = bbox[2] - bbox[0], bbox[3] - bbox[1]

    badge_w, badge_h = text_w + pad_x * 2, text_h + pad_y * 2
    x1 = im.width - margin - badge_w
    y1 = im.height - margin - badge_h
    x2, y2 = x1 + badge_w, y1 + badge_h

    draw.rounded_rectangle([x1, y1, x2, y2], radius=6, fill=(15, 30, 60, 165))
    draw.text((x1 + pad_x - bbox[0], y1 + pad_y - bbox[1]), text, font=font, fill=(255, 255, 255, 235))

    return Image.alpha_composite(im, overlay).convert("RGB")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("--text", default="edebiyatyarismalari.com")
    parser.add_argument("--quality", type=int, default=82)
    parser.add_argument("--no-watermark", action="store_true")
    parser.add_argument("--resize", action="store_true", help="force-crop to 1200x630 (usually not needed, see module docstring)")
    args = parser.parse_args()

    im = Image.open(args.input)
    im = im.convert("RGB")
    if args.resize:
        im = cover_resize_crop(im, *TARGET_SIZE)

    if not args.no_watermark:
        im = add_watermark(im, args.text)

    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)

    ext = os.path.splitext(args.output)[1].lower()
    if ext in (".jpg", ".jpeg"):
        im.save(args.output, "JPEG", quality=args.quality)
    elif ext == ".png":
        im.save(args.output, "PNG")
    else:
        im.save(args.output, "WEBP", quality=args.quality, method=6)

    in_size = os.path.getsize(args.input)
    out_size = os.path.getsize(args.output)
    print(f"{args.input} ({in_size // 1024} KB) -> {args.output} ({out_size // 1024} KB)")


if __name__ == "__main__":
    main()
