"""Cross-platform ffmpeg discovery.

Resolution order
----------------
Windows:
  1. Project-bundled binary at ``ipmx/ffmpeg/bin/ffmpeg.exe``
  2. System PATH

Linux / macOS:
  1. ``/usr/local/bin/ffmpeg`` — installed Matrox build (preferred)
  2. In-tree Matrox sandbox build (``ffmpeg-matrox/src/matrox-build/ffmpeg``)
     with ``LD_LIBRARY_PATH`` set for its private shared libraries
  3. System PATH
"""

from __future__ import annotations

import os
import shutil
from pathlib import Path

# Project-local Windows binary shipped alongside the test tools.
_WIN_FFMPEG = (
    Path(__file__).resolve().parent.parent.parent / "ffmpeg" / "bin" / "ffmpeg.exe"
)

# Matrox in-tree Linux build (adds -hdcp_scramble / -privacy_scramble).
_MATROX_BUILD_DIR = (
    Path(__file__).resolve().parent.parent / "ffmpeg-matrox" / "src" / "matrox-build"
)
_MATROX_FFMPEG_BIN = _MATROX_BUILD_DIR / "ffmpeg"


def find_ffmpeg() -> tuple[str, dict | None]:
    """Return ``(ffmpeg_path, env_or_None)``.

    *env_or_None* is a modified ``os.environ`` dict when the in-tree Matrox
    build is selected (it needs ``LD_LIBRARY_PATH``); otherwise ``None``
    (meaning: inherit the current process environment as-is).

    Raises ``SystemExit`` when no usable ffmpeg binary is found.
    """
    if os.name == "nt":
        # Windows: prefer the bundled binary
        if _WIN_FFMPEG.exists():
            return str(_WIN_FFMPEG), None
        found = shutil.which("ffmpeg")
        if found:
            return found, None
        raise SystemExit(
            f"ffmpeg not found.  Expected at {_WIN_FFMPEG} or on PATH."
        )

    # Linux / macOS
    if Path("/usr/local/bin/ffmpeg").exists():
        return "/usr/local/bin/ffmpeg", None

    if _MATROX_FFMPEG_BIN.exists():
        lib_dirs = os.pathsep.join(
            str(_MATROX_BUILD_DIR / d)
            for d in (
                "libavformat",
                "libavcodec",
                "libavutil",
                "libswscale",
                "libswresample",
            )
        )
        env = os.environ.copy()
        existing = env.get("LD_LIBRARY_PATH", "")
        env["LD_LIBRARY_PATH"] = (
            (lib_dirs + os.pathsep + existing) if existing else lib_dirs
        )
        return str(_MATROX_FFMPEG_BIN), env

    found = shutil.which("ffmpeg")
    if found:
        return found, None
    raise SystemExit("ffmpeg not found in PATH")


# ffmpeg-enhanced build (FFmpeg 8.1 + IPMX). Same FFMPEG_SRC_ROOT convention as
# ipmx/stream_ipmx.sh; defaults to the sibling usb/ffmpeg-enhanced checkout.
_ENHANCED_SRC_ROOT_DEFAULT = Path(__file__).resolve().parent.parent / "usb" / "ffmpeg-enhanced"


def find_ffmpeg_enhanced() -> tuple[str, dict]:
    """Return ``(ffmpeg_path, env)`` for the ffmpeg-enhanced build.

    Used for steps that need options only that build provides (e.g. the
    hevc_metadata ``nal_hrd_bit_rate`` / ``nal_hrd_cpb_size`` options).
    *env* carries ``LD_LIBRARY_PATH`` for the build's shared libraries.

    Raises ``SystemExit`` when the build is not found.
    """
    src_root = Path(os.environ.get("FFMPEG_SRC_ROOT", str(_ENHANCED_SRC_ROOT_DEFAULT)))
    build_dir = src_root / "src" / "matrox-build"
    binary = build_dir / "ffmpeg"
    if not binary.exists():
        raise SystemExit(
            f"ffmpeg-enhanced not found at {binary} (set FFMPEG_SRC_ROOT to the checkout)."
        )
    lib_dirs = os.pathsep.join(
        str(build_dir / d)
        for d in ("libavformat", "libavcodec", "libavutil", "libavfilter",
                  "libavdevice", "libswscale", "libswresample")
    )
    env = os.environ.copy()
    existing = env.get("LD_LIBRARY_PATH", "")
    env["LD_LIBRARY_PATH"] = (lib_dirs + os.pathsep + existing) if existing else lib_dirs
    return str(binary), env
