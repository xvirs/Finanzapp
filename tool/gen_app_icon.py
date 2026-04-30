#!/usr/bin/env python3
"""
Genera el PNG del logo de Finanzapp para usarlo como icono de app y
splash. Replica el FzLogo del design system (handoff/flutter/lib/design):
cuadrado verde #1FB87A con esquinas redondeadas (~26% del lado) y
símbolo "$" blanco extra-bold centrado.

Uso:
    python3 tool/gen_app_icon.py
    # genera assets/icons/app_icon.png (1024x1024)
"""
from PIL import Image, ImageDraw, ImageFont
import os
import sys

# Tokens del design system (lib/design/tokens.dart)
BG_COLOR = (0x1F, 0xB8, 0x7A, 255)   # FzColors.primary verde
FG_COLOR = (0x04, 0x13, 0x0C, 255)   # FzColors.primaryInk (NO blanco!
                                       # el FzLogo del design system usa
                                       # primaryInk como fg, casi negro
                                       # con un toque verde — eso es lo
                                       # que se ve en el login).
SIZE = 1024                            # target output size (estándar
                                       # para flutter_launcher_icons)
SUPERSAMPLE = 4                        # renderiza 4x más grande y
                                       # downsamplea con LANCZOS para
                                       # bordes lisos
RADIUS_RATIO = 0.26                    # esquinas como en FzLogo
FONT_RATIO = 0.55                      # tamaño del $ vs canvas

# Fuentes candidatas (macOS first, fallbacks). PIL no maneja Inter
# o Geist por default, pero Helvetica/Arial bold se parece visualmente
# al $ del FzLogo.
FONT_CANDIDATES = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/System/Library/Fonts/Avenir Next.ttc",
    "/Library/Fonts/Arial Bold.ttf",
]


def find_font(size):
    for path in FONT_CANDIDATES:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return ImageFont.load_default()


def draw_logo(canvas_size=SIZE, transparent_bg=False):
    """Devuelve una imagen RGBA con el logo. Renderiza a SUPERSAMPLE x
    el tamaño final y downsamplea con LANCZOS para bordes lisos en el $
    y en las esquinas redondeadas. Si transparent_bg=True omite el
    cuadrado verde (útil para foreground de adaptive icon)."""
    big = canvas_size * SUPERSAMPLE
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    if not transparent_bg:
        radius = int(big * RADIUS_RATIO)
        draw.rounded_rectangle(
            [(0, 0), (big, big)],
            radius=radius,
            fill=BG_COLOR,
        )

    # Dibujar el "$" centrado.
    font_size = int(big * FONT_RATIO)
    font = find_font(font_size)
    text = "$"

    # textbbox da (left, top, right, bottom).
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    x = (big - text_w) / 2 - bbox[0]
    # Ajuste vertical: el $ tiene mucho whitespace abajo del baseline,
    # así que centramos por bbox no por baseline.
    y = (big - text_h) / 2 - bbox[1]

    draw.text((x, y), text, fill=FG_COLOR, font=font)
    # Downsamplea con filtro LANCZOS para máxima nitidez.
    return img.resize((canvas_size, canvas_size), Image.LANCZOS)


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(here)
    out_dir = os.path.join(project_root, "assets", "icons")
    os.makedirs(out_dir, exist_ok=True)

    icon = draw_logo(SIZE)
    icon_path = os.path.join(out_dir, "app_icon.png")
    icon.save(icon_path, "PNG")
    print(f"Wrote {icon_path} ({SIZE}x{SIZE})")

    # Adaptive icon foreground: cuadrado verde fullbleed sobre canvas
    # transparente. El padding lo agrega el `inset 16%` que
    # flutter_launcher_icons declara en el adaptive-icon XML — eso ya
    # cubre la safe zone de Android (Material crop ~16% por lado).
    # Si pongo padding también acá, los paddings se suman y el cuadrado
    # verde queda demasiado chico (no parecido al FzLogo del login).
    fg = draw_logo(SIZE)
    fg_path = os.path.join(out_dir, "app_icon_foreground.png")
    fg.save(fg_path, "PNG")
    print(f"Wrote {fg_path} ({SIZE}x{SIZE}, fullbleed)")


if __name__ == "__main__":
    sys.exit(main())
