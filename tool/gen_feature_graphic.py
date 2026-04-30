#!/usr/bin/env python3
"""
Genera el feature graphic 1024x500 que requiere Google Play Store
para el listing de la app.

Diseño:
- Fondo radial verde oscuro → casi negro (consistente con halo del login).
- Logo cuadrado con $ a la izquierda.
- Texto "Finanzapp" + tagline a la derecha.

Uso:
    python3 tool/gen_feature_graphic.py
    # genera assets/store/feature_graphic.png (1024x500)
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

# Tokens del design system (lib/design/tokens.dart) — match con app.
PRIMARY = (0x1F, 0xB8, 0x7A, 255)      # FzColors.primary
PRIMARY_INK = (0x04, 0x13, 0x0C, 255)   # FzColors.primaryInk
BG_DARK = (0x0B, 0x0F, 0x0D, 255)       # FzColors.bg dark
TEXT = (0xE8, 0xED, 0xEA, 255)
TEXT_MUTE = (0x8A, 0x95, 0x8F, 255)

W, H = 1024, 500
SUPERSAMPLE = 2  # 2x → downsample a tamaño final con LANCZOS

FONT_CANDIDATES_BOLD = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/Library/Fonts/Arial Bold.ttf",
]
FONT_CANDIDATES_REGULAR = [
    "/System/Library/Fonts/Helvetica.ttc",
    "/System/Library/Fonts/Supplemental/Arial.ttf",
]


def find_font(candidates, size):
    for path in candidates:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return ImageFont.load_default()


def draw_halo(canvas, center, color, radius, blur_radius):
    """Dibuja un halo radial smooth: una elipse sólida + GaussianBlur
    fuerte. Se ve mucho más limpio que un gradient radial por steps."""
    cx, cy = center
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    ld.ellipse(
        [(cx - radius, cy - radius), (cx + radius, cy + radius)],
        fill=color,
    )
    layer = layer.filter(ImageFilter.GaussianBlur(blur_radius))
    canvas.alpha_composite(layer)


def draw_logo_box(canvas, size, position):
    """Dibuja un cuadrado verde con $ centrado, tipo FzLogo."""
    x, y = position
    big_size = size * SUPERSAMPLE
    box = Image.new("RGBA", (big_size, big_size), (0, 0, 0, 0))
    bd = ImageDraw.Draw(box)

    radius = int(big_size * 0.26)
    bd.rounded_rectangle(
        [(0, 0), (big_size, big_size)],
        radius=radius,
        fill=PRIMARY,
    )

    font_size = int(big_size * 0.55)
    font = find_font(FONT_CANDIDATES_BOLD, font_size)
    text = "$"
    bbox = bd.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    tx = (big_size - text_w) / 2 - bbox[0]
    ty = (big_size - text_h) / 2 - bbox[1]
    bd.text((tx, ty), text, fill=PRIMARY_INK, font=font)

    box = box.resize((size, size), Image.LANCZOS)
    canvas.alpha_composite(box, (x, y))


def main():
    big_w, big_h = W * SUPERSAMPLE, H * SUPERSAMPLE
    img = Image.new("RGBA", (big_w, big_h), BG_DARK)

    # Halo verde intenso pero blureado (mismo concepto que login screen).
    # Gaussian blur fuerte → smooth sin banding.
    halo_center = (int(big_w * 0.30), big_h // 2)
    halo_color = (0x1F, 0xB8, 0x7A, 130)  # verde con alpha
    halo_radius = int(big_h * 0.45)
    halo_blur = int(big_h * 0.30)
    draw_halo(img, halo_center, halo_color, halo_radius, halo_blur)

    # Halo secundario más interno y fuerte para dar depth.
    inner_halo_color = (0x4D, 0xD4, 0x9A, 80)
    inner_halo_radius = int(big_h * 0.18)
    inner_halo_blur = int(big_h * 0.18)
    draw_halo(img, halo_center, inner_halo_color, inner_halo_radius, inner_halo_blur)

    # Downsample.
    img = img.resize((W, H), Image.LANCZOS)
    draw = ImageDraw.Draw(img)

    # Logo a la izquierda.
    logo_size = 200
    logo_x = 110
    logo_y = (H - logo_size) // 2
    draw_logo_box(img, logo_size, (logo_x, logo_y))

    # Texto a la derecha.
    text_x = logo_x + logo_size + 56
    title_font = find_font(FONT_CANDIDATES_BOLD, 78)
    tag_font = find_font(FONT_CANDIDATES_REGULAR, 28)

    title = "Finanzapp"
    tag1 = "Control de gastos recurrentes"
    tag2 = "obligatorios"

    # Centrado vertical del bloque de texto.
    bbox_t = draw.textbbox((0, 0), title, font=title_font)
    bbox_l1 = draw.textbbox((0, 0), tag1, font=tag_font)
    bbox_l2 = draw.textbbox((0, 0), tag2, font=tag_font)
    title_h = bbox_t[3] - bbox_t[1]
    tag1_h = bbox_l1[3] - bbox_l1[1]
    tag2_h = bbox_l2[3] - bbox_l2[1]
    total_h = title_h + 18 + tag1_h + 8 + tag2_h
    y_start = (H - total_h) // 2 - bbox_t[1]

    draw.text((text_x, y_start), title, fill=TEXT, font=title_font)
    draw.text(
        (text_x, y_start + title_h + 18 - bbox_l1[1]),
        tag1,
        fill=TEXT_MUTE,
        font=tag_font,
    )
    draw.text(
        (text_x, y_start + title_h + 18 + tag1_h + 8 - bbox_l2[1]),
        tag2,
        fill=TEXT_MUTE,
        font=tag_font,
    )

    here = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(here)
    out_dir = os.path.join(project_root, "assets", "store")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "feature_graphic.png")
    # Convertir a RGB (Play Store no acepta alpha).
    img.convert("RGB").save(out_path, "PNG")
    print(f"Wrote {out_path} ({W}x{H})")


if __name__ == "__main__":
    sys.exit(main())
