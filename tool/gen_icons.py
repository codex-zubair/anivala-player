#!/usr/bin/env python3
"""Generate AniLoom branding PNGs with no third-party dependencies.

Draws the AniLoom mark — three violet/cyan "loom" threads behind a play
triangle — as:
  <app_root>/assets/images/app_icon.png             (512, gradient background)
  <app_root>/assets/images/app_icon_foreground.png  (1024, transparent, adaptive)
  <app_root>/assets/images/splash_logo.png          (512, transparent)
  <app_root>/assets/images/play_icon_512.png        (512, Play Store icon)

Usage:
  python3 gen_icons.py [app_root]     (default: current directory)
"""
import math
import struct
import sys
import zlib
from pathlib import Path

APP_ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
OUT = APP_ROOT / "assets" / "images"
OUT.mkdir(parents=True, exist_ok=True)

BG = (0x0A, 0x0E, 0x1A)
ACCENT = (0x7C, 0x5C, 0xFF)  # violet
ACCENT2 = (0x22, 0xD3, 0xEE)  # cyan


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def write_png(path, width, height, pixels):
    raw = bytearray()
    for row in pixels:
        raw.append(0)
        for r, g, b, a in row:
            raw += bytes((r, g, b, a))
    compressed = zlib.compress(bytes(raw), 9)

    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data +
                struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))

    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png = (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) +
           chunk(b"IDAT", compressed) + chunk(b"IEND", b""))
    path.write_bytes(png)


def _edge(d):
    if d >= 0.5:
        return 1.0
    if d <= -0.5:
        return 0.0
    return d + 0.5


def segment_coverage(x, y, ax, ay, bx, by, half_width):
    vx, vy = bx - ax, by - ay
    wx, wy = x - ax, y - ay
    seg_len2 = vx * vx + vy * vy
    t = 0.0 if seg_len2 == 0 else max(0.0, min(1.0, (wx * vx + wy * vy) / seg_len2))
    px, py = ax + t * vx, ay + t * vy
    return _edge(half_width - math.hypot(x - px, y - py))


def point_in_triangle(px, py, a, b, c):
    def sign(p1, p2, p3):
        return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1])

    d1 = sign((px, py), a, b)
    d2 = sign((px, py), b, c)
    d3 = sign((px, py), c, a)
    has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0)
    has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0)
    return not (has_neg and has_pos)


def rounded_square_bg(x, y, cx, cy, half, radius):
    dx = abs(x - cx) - (half - radius)
    dy = abs(y - cy) - (half - radius)
    if dx < 0:
        dx = 0
    if dy < 0:
        dy = 0
    dist = math.hypot(dx, dy)
    return _edge(radius - dist)


def render(size, with_background, scale=1.0, supersample=2):
    pixels = [[(0, 0, 0, 0)] * size for _ in range(size)]
    cx = cy = size / 2.0
    half = (size / 2.0) * 0.78

    # Geometry for the mark (in the scaled drawing box).
    box = (size / 2.0) * 0.72 * scale
    x0, y0, x1, y1 = cx - box, cy - box, cx + box, cy + box

    # Three vertical loom threads.
    thread_hw = size * 0.022
    threads = []
    for fx in (0.32, 0.5, 0.68):
        tx = x0 + (x1 - x0) * fx
        threads.append((tx, y0 + box * 0.10, tx, y1 - box * 0.10))

    # Play triangle.
    tri = (
        (x0 + box * 0.40, y0 + box * 0.20),
        (x0 + box * 0.40, y1 - box * 0.20),
        (x1 - box * 0.06, cy),
    )

    ss = supersample
    n = ss * ss
    for py in range(size):
        for px in range(size):
            acc = [0.0, 0.0, 0.0, 0.0]
            for sy in range(ss):
                for sx in range(ss):
                    fx = px + (sx + 0.5) / ss
                    fy = py + (sy + 0.5) / ss

                    r = g = b = 0.0
                    a = 0.0

                    if with_background:
                        bg_a = rounded_square_bg(
                            fx, fy, cx, cy, size * 0.5, size * 0.25)
                        sheen = max(0.0, min(1.0, (fx + fy) / (2 * size)))
                        bg_rgb = lerp(BG, (0x14, 0x1B, 0x2E), sheen * 0.9)
                        r, g, b, a = bg_rgb[0], bg_rgb[1], bg_rgb[2], bg_a

                    # Gradient tone by position.
                    gt = max(0.0, min(1.0, ((fx - x0) + (fy - y0)) / (2 * box)))
                    thread_rgb = lerp(ACCENT, ACCENT2, 0.35 + gt * 0.4)
                    tri_rgb = lerp(ACCENT, ACCENT2, gt)

                    for (ax, ay, bx, by) in threads:
                        cov = segment_coverage(fx, fy, ax, ay, bx, by, thread_hw)
                        if cov > 0:
                            ta = cov * 0.45
                            r = r * (1 - ta) + thread_rgb[0] * ta
                            g = g * (1 - ta) + thread_rgb[1] * ta
                            b = b * (1 - ta) + thread_rgb[2] * ta
                            a = a * (1 - ta) + 1.0 * ta

                    if point_in_triangle(fx, fy, *tri):
                        ta = 1.0
                        r = r * (1 - ta) + tri_rgb[0] * ta
                        g = g * (1 - ta) + tri_rgb[1] * ta
                        b = b * (1 - ta) + tri_rgb[2] * ta
                        a = a * (1 - ta) + 1.0 * ta

                    acc[0] += r * a
                    acc[1] += g * a
                    acc[2] += b * a
                    acc[3] += a

            alpha = acc[3] / n
            if alpha <= 0.0001:
                pixels[py][px] = (0, 0, 0, 0)
            else:
                pixels[py][px] = (
                    int(round(min(255.0, acc[0] / acc[3]))),
                    int(round(min(255.0, acc[1] / acc[3]))),
                    int(round(min(255.0, acc[2] / acc[3]))),
                    int(round(alpha * 255)),
                )
    return pixels


def main():
    icon = render(512, with_background=True, scale=1.0)
    write_png(OUT / "app_icon.png", 512, 512, icon)
    write_png(OUT / "play_icon_512.png", 512, 512, icon)

    fg = render(1024, with_background=False, scale=0.82)
    write_png(OUT / "app_icon_foreground.png", 1024, 1024, fg)

    splash = render(512, with_background=False, scale=0.95)
    write_png(OUT / "splash_logo.png", 512, 512, splash)

    for name in ("app_icon.png", "app_icon_foreground.png",
                 "splash_logo.png", "play_icon_512.png"):
        p = OUT / name
        print(f"  {name}: {p.stat().st_size} bytes")


if __name__ == "__main__":
    main()
