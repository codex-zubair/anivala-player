#!/usr/bin/env python3
"""Render AniLoom Play Store graphics and the Android TV banner as HTML
mockups, screenshotted with headless Chrome. No third-party Python deps.

Writes:
  <app>/store_assets/graphics/feature_graphic_1024x500.png
  <app>/store_assets/screenshots/01..05_*.png            (1080x1920)
  <app>/android/app/src/main/res/drawable-xhdpi/tv_banner.png  (320x180)

Usage:
  python3 make_graphics.py [app_root]
"""
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

APP_ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
GRAPHICS = APP_ROOT / "store_assets" / "graphics"
SHOTS = APP_ROOT / "store_assets" / "screenshots"
TV = APP_ROOT / "android" / "app" / "src" / "main" / "res" / "drawable-xhdpi"
for d in (GRAPHICS, SHOTS, TV):
    d.mkdir(parents=True, exist_ok=True)

CHROME = (shutil.which("google-chrome-stable") or shutil.which("google-chrome")
          or shutil.which("brave") or shutil.which("chromium"))

CSS = """
*{margin:0;padding:0;box-sizing:border-box;-webkit-font-smoothing:antialiased}
body{font-family:'DejaVu Sans','Segoe UI',Roboto,sans-serif;background:#0A0E1A;color:#EAF0FB}
.screen{width:1080px;height:1920px;padding:0 0 0 0;position:relative;display:flex;flex-direction:column;overflow:hidden}
.safe{padding:54px 44px 0}
.status{display:flex;justify-content:space-between;font-size:28px;color:#93A1BD;padding:22px 40px 0}
.hdr{display:flex;align-items:center;gap:18px;padding:18px 44px 22px}
.logo{width:72px;height:72px;border-radius:22px;background:linear-gradient(135deg,#7C5CFF,#22D3EE);display:flex;align-items:center;justify-content:center;position:relative}
.logo .tri{width:0;height:0;border-left:30px solid #0A0E1A;border-top:19px solid transparent;border-bottom:19px solid transparent;margin-left:8px}
.threads{position:absolute;left:0;top:0;right:0;bottom:0;border-radius:22px;overflow:hidden}
.threads i{position:absolute;top:18%;bottom:18%;width:6px;background:rgba(10,14,26,.42);border-radius:4px}
.word{font-size:44px;font-weight:800;letter-spacing:-1px}
.word small{display:block;font-size:22px;font-weight:500;color:#93A1BD;letter-spacing:0}
.chip{margin-left:auto;display:flex;align-items:center;gap:10px;background:#141A2B;border:2px solid #243048;border-radius:40px;padding:14px 24px;font-size:24px;color:#93A1BD;font-weight:600}
.chip .d{color:#22D3EE}
.sect{color:#657395;font-size:22px;font-weight:800;letter-spacing:3px;margin:22px 44px 16px}
.card{background:#141A2B;border:2px solid #243048;border-radius:26px;padding:30px;margin:0 44px 22px;display:flex;gap:22px;align-items:center}
.thumb{width:190px;height:118px;border-radius:16px;flex:0 0 auto;position:relative;overflow:hidden}
.thumb .play{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;color:rgba(255,255,255,.85);font-size:40px}
.bar{position:absolute;left:0;right:0;bottom:0;height:7px;background:rgba(0,0,0,.5)}
.bar i{display:block;height:100%;background:#22D3EE}
.tt{font-size:30px;font-weight:800}
.ts{color:#93A1BD;font-size:23px;margin-top:8px}
.tp{color:#22D3EE;font-size:23px;font-weight:700;margin-top:10px}
.grid{display:grid;grid-template-columns:1fr 1fr;gap:24px;padding:0 44px}
.gcard{background:#141A2B;border:2px solid #243048;border-radius:24px;padding:16px}
.gthumb{width:100%;height:220px;border-radius:16px;position:relative;overflow:hidden;margin-bottom:14px}
.gtitle{font-size:26px;font-weight:700}
.gsub{color:#93A1BD;font-size:21px;margin-top:6px}
.badge{display:inline-block;background:rgba(255,180,84,.14);color:#FFB454;border:2px solid rgba(255,180,84,.4);border-radius:18px;padding:6px 16px;font-size:20px;font-weight:700}
.pill{display:inline-block;background:rgba(34,211,238,.14);color:#22D3EE;border:2px solid rgba(34,211,238,.4);border-radius:20px;padding:8px 18px;font-size:21px;font-weight:700}
.player{flex:1;display:flex;flex-direction:column;justify-content:flex-end;background:linear-gradient(180deg,#161B2C,#05070E)}
.pcontrols{background:linear-gradient(0deg,rgba(0,0,0,.85),transparent);padding:40px 60px 70px}
.prow{display:flex;align-items:center;justify-content:center;gap:60px;margin-bottom:34px}
.prow .big{font-size:120px;color:#fff}
.prow .sm{font-size:74px;color:#cbd5e1}
.ptime{display:flex;align-items:center;gap:20px;color:#cbd5e1;font-size:24px}
.ptrack{flex:1;height:9px;background:rgba(255,255,255,.22);border-radius:6px;position:relative}
.ptrack i{display:block;height:100%;border-radius:6px;background:#22D3EE}
.ptrack b{position:absolute;top:-8px;width:26px;height:26px;border-radius:50%;background:#22D3EE;left:52%}
.ptitle{color:#fff;font-size:34px;font-weight:800;margin-bottom:26px;text-align:center}
.nav{position:absolute;left:0;right:0;bottom:0;height:150px;background:#0C1120;border-top:2px solid #1B2338;display:flex;align-items:center;justify-content:space-around;padding-bottom:14px}
.nav .it{display:flex;flex-direction:column;align-items:center;gap:8px;color:#657395;font-size:20px}
.nav .it.on{color:#22D3EE}
.nav .ic{width:56px;height:56px;border-radius:16px;background:#182034;display:flex;align-items:center;justify-content:center;font-size:30px}
.nav .on .ic{background:rgba(34,211,238,.18)}
.feature{width:1024px;height:500px;background:radial-gradient(120% 160% at 15% 10%,#1A1140 0%,#0A0E1A 55%,#05070E 100%);position:relative;overflow:hidden;display:flex;align-items:center;padding:0 70px}
.fglow{position:absolute;right:-120px;top:-140px;width:560px;height:560px;border-radius:50%;background:radial-gradient(circle,rgba(124,92,255,.5),transparent 62%)}
.fglow2{position:absolute;right:120px;bottom:-220px;width:520px;height:520px;border-radius:50%;background:radial-gradient(circle,rgba(34,211,238,.35),transparent 62%)}
.fleft{z-index:2;display:flex;align-items:center;gap:34px}
.flogo{width:170px;height:170px;border-radius:46px;background:linear-gradient(135deg,#7C5CFF,#22D3EE);position:relative;display:flex;align-items:center;justify-content:center;box-shadow:0 30px 70px rgba(124,92,255,.5)}
.ftri{width:0;height:0;border-left:64px solid #0A0E1A;border-top:42px solid transparent;border-bottom:42px solid transparent;margin-left:16px}
.fname{font-size:88px;font-weight:900;letter-spacing:-3px}
.ftag{font-size:34px;color:#AEB9D6;margin-top:6px}
.fbadges{display:flex;gap:14px;margin-top:24px}
.fb{font-size:26px;font-weight:800;border-radius:16px;padding:12px 22px}
.fb1{color:#22D3EE;background:rgba(34,211,238,.14);border:2px solid rgba(34,211,238,.4)}
.fb2{color:#FFB454;background:rgba(255,180,84,.13);border:2px solid rgba(255,180,84,.4)}
.fb3{color:#7C5CFF;background:rgba(124,92,255,.16);border:2px solid rgba(124,92,255,.5)}
.tv{width:320px;height:180px;background:linear-gradient(135deg,#160F35,#0A0E1A);display:flex;align-items:center;gap:20px;padding:0 26px;overflow:hidden;position:relative}
.tvlogo{width:84px;height:84px;border-radius:24px;background:linear-gradient(135deg,#7C5CFF,#22D3EE);display:flex;align-items:center;justify-content:center;position:relative}
.tvtri{width:0;height:0;border-left:34px solid #0A0E1A;border-top:22px solid transparent;border-bottom:22px solid transparent;margin-left:8px}
.tvname{font-size:44px;font-weight:900;color:#fff;letter-spacing:-1px}
.tvtag{font-size:19px;color:#AEB9D6}
"""


def render_html(html: str, out: Path, w: int, h: int) -> None:
    if CHROME is None:
        print("No Chrome found; skipping", out.name)
        return
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False) as f:
        f.write(html)
        path = f.name
    subprocess.run(
        [CHROME, "--headless=new", "--no-sandbox", "--disable-gpu",
         "--hide-scrollbars", "--force-device-scale-factor=1",
         f"--window-size={w},{h}", f"--screenshot={out}", f"file://{path}"],
        check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    Path(path).unlink(missing_ok=True)
    print(f"  {out.relative_to(APP_ROOT)}")


def page(body: str, w: int, h: int) -> str:
    return (f"<!DOCTYPE html><html><head><meta charset='utf-8'><style>"
            f"{CSS}\nhtml,body{{width:{w}px;height:{h}px}}</style></head>"
            f"<body>{body}</body></html>")


def thumb(grad: str, pct: int) -> str:
    bar = f"<div class='bar'><i style='width:{pct}%'></i></div>" if pct else ""
    return (f"<div class='thumb' style='background:{grad}'>"
            f"<div class='play'>&#9654;</div>{bar}</div>")


def gthumb(grad: str) -> str:
    return (f"<div class='gthumb' style='background:{grad}'>"
            f"<div class='play' style='position:absolute;inset:0;display:flex;"
            f"align-items:center;justify-content:center;color:rgba(255,255,255,.85);"
            f"font-size:56px'>&#9654;</div></div>")


def statusbar() -> str:
    return "<div class='status'><span>9:41</span><span>&#9679; &#9679; &#9679; &#9679;</span></div>"


def header() -> str:
    return ("<div class='hdr'><div class='logo'>"
            "<div class='threads'><i style='left:24%'></i><i style='left:47%'></i>"
            "<i style='left:70%'></i></div><div class='tri'></div></div>"
            "<div class='word'>AniLoom<small>Offline Anime &amp; Video</small></div>"
            "<div class='chip'><span class='d'>&#10003;</span> Offline</div></div>")


def nav(active: int) -> str:
    items = [("&#9654;", "Watching"), ("&#9636;", "Library"),
             ("&#9881;", "Settings"), ("&#9432;", "About")]
    out = []
    for i, (ic, label) in enumerate(items):
        cls = "it on" if i == active else "it"
        out.append(f"<div class='{cls}'><div class='ic'>{ic}</div>{label}</div>")
    return f"<div class='nav'>{''.join(out)}</div>"


# ---- Screens ----

def screen_continue() -> str:
    grad = "linear-gradient(135deg,rgba(124,92,255,.35),#1B2338)"
    grad2 = "linear-gradient(135deg,rgba(34,211,238,.30),#1B2338)"
    grad3 = "linear-gradient(135deg,rgba(255,180,84,.30),#1B2338)"
    cards = ""
    for title, sub, pct, g in [
        ("Frieren — Beyond Journey's End E05", "68% watched · 7:42 left", 68, grad),
        ("Demon Slayer S04E02", "22% watched · 18:03 left", 22, grad2),
        ("Spy x Family E11", "91% watched · 1:58 left", 91, grad3),
    ]:
        cards += (f"<div class='card'>{thumb(g, pct)}<div><div class='tt'>{title}</div>"
                  f"<div class='ts'>{sub}</div>"
                  f"<div class='tp'>&#9654; Resume</div></div></div>")
    body = (f"<div class='screen'>{statusbar()}{header()}"
            f"<div class='sect'>CONTINUE WATCHING</div>"
            f"<div style='padding:0 44px 18px'><span class='pill'>3 in progress</span></div>"
            f"{cards}<div style='padding:0 44px;color:#93A1BD;font-size:22px'>"
            f"Resumes exactly where you left off. Stored only on this device.</div>"
            f"{nav(0)}</div>")
    return page(body, 1080, 1920)


def screen_player() -> str:
    body = (
        "<div class='screen'><div class='player'>"
        "<div style='height:110px'></div>"
        "<div class='ptitle'>Frieren — Beyond Journey&#39;s End E05</div>"
        "<div class='pcontrols'>"
        "<div class='prow'><span class='sm'>&#9198;</span>"
        "<span class='big'>&#9199;</span><span class='sm'>&#9197;</span></div>"
        "<div class='ptime'><span>12:18</span>"
        "<div class='ptrack'><i style='width:62%'></i><b style='left:62%'></b></div>"
        "<span>19:58</span></div></div></div></div>")
    return page(body, 1080, 1920)


def screen_library_grid() -> str:
    grads = ["linear-gradient(135deg,rgba(124,92,255,.35),#1B2338)",
             "linear-gradient(135deg,rgba(34,211,238,.30),#1B2338)",
             "linear-gradient(135deg,rgba(244,114,182,.30),#1B2338)",
             "linear-gradient(135deg,rgba(52,211,153,.28),#1B2338)",
             "linear-gradient(135deg,rgba(255,180,84,.30),#1B2338)",
             "linear-gradient(135deg,rgba(96,165,250,.30),#1B2338)"]
    titles = ["Frieren E05", "Demon Slayer S04E02", "One Piece E1085",
              "Jujutsu Kaisen E23", "Spy x Family E11", "Chainsaw Man E08"]
    folders = ["Frieren", "Demon Slayer", "One Piece",
               "Jujutsu Kaisen", "Spy x Family", "Chainsaw Man"]
    cells = ""
    for g, t, f in zip(grads, titles, folders):
        cells += f"<div class='gcard'>{gthumb(g)}<div class='gtitle'>{t}</div><div class='gsub'>{f}</div></div>"
    body = (f"<div class='screen'>{statusbar()}{header()}"
            f"<div style='padding:0 44px 18px'><div style='background:#141A2B;border:2px solid #243048;"
            f"border-radius:16px;padding:20px 24px;color:#93A1BD;font-size:26px'>"
            f"&#128269; Search your library</div></div>"
            f"<div class='sect'>YOUR LIBRARY · 128 VIDEOS</div>"
            f"<div class='grid'>{cells}</div>{nav(1)}</div>")
    return page(body, 1080, 1920)


def screen_library_list() -> str:
    grads = ["linear-gradient(135deg,rgba(124,92,255,.35),#1B2338)",
             "linear-gradient(135deg,rgba(34,211,238,.30),#1B2338)",
             "linear-gradient(135deg,rgba(255,180,84,.30),#1B2338)",
             "linear-gradient(135deg,rgba(52,211,153,.28),#1B2338)"]
    rows = [("Naruto Shippuden - 012", "Naruto Shippuden · 23:40", True),
            ("Bleach - 245", "Bleach · 24:11", True),
            ("Your Name (2016)", "Movies · 1:46:00", False),
            ("Attack on Titan S01E01", "Attack on Titan · 24:02", True)]
    cards = ""
    for (t, s, anime), g in zip(rows, grads):
        badge = "<div class='badge' style='margin-top:10px'>Anime</div>" if anime else ""
        cards += (f"<div class='card'>{thumb(g, 0)}<div><div class='tt'>{t}</div>"
                  f"<div class='ts'>{s}</div>{badge}</div></div>")
    body = (f"<div class='screen'>{statusbar()}{header()}"
            f"<div class='sect'>GROUPED BY FOLDER</div>{cards}{nav(1)}</div>")
    return page(body, 1080, 1920)


def screen_about() -> str:
    body = (
        f"<div class='screen'>{statusbar()}{header()}"
        "<div style='text-align:center;padding:30px 44px 0'>"
        "<div class='logo' style='margin:0 auto;width:150px;height:150px;border-radius:44px'>"
        "<div class='threads'><i style='left:24%'></i><i style='left:47%'></i>"
        "<i style='left:70%'></i></div>"
        "<div style='width:0;height:0;border-left:64px solid #0A0E1A;"
        "border-top:42px solid transparent;border-bottom:42px solid transparent;"
        "margin-left:16px'></div></div>"
        "<div style='font-size:56px;font-weight:900;letter-spacing:-1px;margin-top:26px'>AniLoom</div>"
        "<div style='color:#93A1BD;font-size:28px;margin-top:6px'>Offline Anime &amp; Video Player</div>"
        "<div style='margin-top:20px'><span class='pill'>v1.0.0 · by codex-zubair</span></div></div>"
        "<div style='margin:44px;background:linear-gradient(135deg,rgba(124,92,255,.16),rgba(34,211,238,.10));"
        "border:2px solid rgba(124,92,255,.4);border-radius:28px;padding:34px'>"
        "<div style='font-size:34px;font-weight:800;color:#22D3EE'>&#128737; Private by design</div>"
        "<div style='color:#EAF0FB;font-size:28px;line-height:1.55;margin-top:14px'>"
        "No internet, no ads, no tracking. Your library and playback history stay on your device.</div></div>"
        "<div style='margin:0 44px'>"
        "<div class='card'><div style='font-size:30px;font-weight:800'>No INTERNET permission</div></div>"
        "<div class='card'><div style='font-size:30px;font-weight:800'>No ads · no analytics</div></div>"
        "<div class='card'><div style='font-size:30px;font-weight:800'>100% offline playback</div></div>"
        "</div></div>")
    return page(body, 1080, 1920)


def feature_graphic() -> str:
    body = (
        "<div class='feature'><div class='fglow'></div><div class='fglow2'></div>"
        "<div class='fleft'><div class='flogo'>"
        "<div class='threads' style='border-radius:46px'><i style='left:24%'></i>"
        "<i style='left:47%'></i><i style='left:70%'></i></div>"
        "<div class='ftri'></div></div>"
        "<div><div class='fname'>AniLoom</div>"
        "<div class='ftag'>Your offline anime &amp; video player</div>"
        "<div class='fbadges'><span class='fb fb1'>&#10003; 100% offline</span>"
        "<span class='fb fb2'>No ads</span>"
        "<span class='fb fb3'>Continue Watching</span></div></div></div></div>")
    return page(body, 1024, 500)


def tv_banner() -> str:
    body = ("<div class='tv'><div class='tvlogo'>"
            "<div class='threads' style='border-radius:24px'><i style='left:24%'></i>"
            "<i style='left:47%'></i><i style='left:70%'></i></div>"
            "<div class='tvtri'></div></div>"
            "<div><div class='tvname'>AniLoom</div>"
            "<div class='tvtag'>Offline anime &amp; video</div></div></div>")
    return page(body, 320, 180)


def main():
    if CHROME is None:
        print("Chrome not found; cannot render graphics.")
        return
    render_html(feature_graphic(), GRAPHICS / "feature_graphic_1024x500.png", 1024, 500)
    render_html(tv_banner(), TV / "tv_banner.png", 320, 180)
    shots = [
        ("01_continue_watching", screen_continue()),
        ("02_player", screen_player()),
        ("03_library_grid", screen_library_grid()),
        ("04_library_list", screen_library_list()),
        ("05_about_privacy", screen_about()),
    ]
    for name, html in shots:
        render_html(html, SHOTS / f"{name}.png", 1080, 1920)


if __name__ == "__main__":
    main()
