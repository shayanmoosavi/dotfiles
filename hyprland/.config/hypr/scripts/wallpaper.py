"""Wallpaper picker and setter module for Hyprland.

Sets wallpaper and generate a color palette from it using Matugen and Wallust.
"""

import os
import subprocess
import sys
from configparser import ConfigParser
from pathlib import Path

# Make lib.utils and refresh importable from the same scripts/ directory.
sys.path.insert(0, str(Path(__file__).parent))
import refresh
from lib.utils import log

# Paths
# ------------------------------------------------------------------------------

WAYPAPER_CONFIG = Path.home() / ".config/waypaper/config.ini"
HYPRLOCK_WALLPAPER = Path.home() / ".config/hypr/current_wallpaper"
SDDM_SCRIPT = Path(__file__).parent / "update_sddm.py"

# Helpers
# ------------------------------------------------------------------------------


def get_mtime(path: Path) -> float:
    """
    Gets the last modification time of a file.

    Args:
        path (pathlib.Path): The path to the file.

    Returns:
        float: mtime of a file, or 0.0 if it doesn't exist.
    """
    try:
        return path.stat().st_mtime
    except FileNotFoundError:
        return 0.0


def read_wallpaper_from_config() -> Path | None:
    """
    Parse Waypaper's config.ini and return the selected wallpaper path.

    Returns:
        The path to the wallpaper, or None if not set.
    """
    config = ConfigParser()
    config.read(WAYPAPER_CONFIG)

    raw = config.get("Settings", "wallpaper", fallback="").strip()
    if not raw:
        return None

    # expanduser handles the ~ that waypaper writes into the config.
    return Path(os.path.expanduser(raw))


def link_for_hyprlock(wallpaper: Path) -> None:
    """
    Symlink the selected wallpaper to the path hyprlock expects.

    Args:
        wallpaper (pathlib.Path): The path to the selected wallpaper.
    """
    HYPRLOCK_WALLPAPER.unlink(missing_ok=True)
    HYPRLOCK_WALLPAPER.symlink_to(wallpaper)


def launch_sddm_update(wallpaper: Path) -> None:
    """
    Run update_sddm.py in a kitty terminal via hyprctl.

    Args:
        wallpaper (pathlib.Path): The path to the selected wallpaper.
    """
    cmd = (
        'kitty --title="Update SDDM Wallpaper"'
        f' -e python3 {SDDM_SCRIPT} "{str(wallpaper)}"'
    )
    subprocess.Popen(["hyprctl", "dispatch", f"hl.dsp.exec_cmd('{cmd}')"])


def generate_palette(wallpaper: Path) -> None:
    """
    Run wallust and matugen to derive a color palette from the wallpaper.

    Args:
        wallpaper (pathlib.Path): The path to the selected wallpaper.
    """
    print("Generating color palette from current wallpaper...")

    for cmd in [
        ["wallust", "run", str(wallpaper)],
        ["matugen", "image", str(wallpaper)],
        ["notify-send", "-e", "󰏘 Theme Applied", "Theme applied successfully."],
    ]:
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


# Entry point
# ------------------------------------------------------------------------------


def main() -> None:
    # Record config mtime before opening the picker
    old_mtime = get_mtime(WAYPAPER_CONFIG)

    # Open waypaper (blocking — we wait for the user to pick)
    result = subprocess.run(
        ["waypaper"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    if result.returncode != 0:
        print("Waypaper exited with an error. Aborting.", file=sys.stderr)
        sys.exit(1)

    # Check whether a wallpaper was actually selected
    if not WAYPAPER_CONFIG.exists():
        print("ERROR: waypaper config not found after picker closed.", file=sys.stderr)
        sys.exit(1)

    if get_mtime(WAYPAPER_CONFIG) == old_mtime:
        # Config unchanged — user dismissed the picker without selecting.
        print("No wallpaper selected. Exiting.", file=sys.stderr)
        sys.exit(0)

    # Read the chosen wallpaper path
    wallpaper = read_wallpaper_from_config()
    if wallpaper is None or not wallpaper.exists():
        print(f"ERROR: wallpaper file not found: {wallpaper}", file=sys.stderr)
        sys.exit(1)

    # Apply the wallpaper
    try:
        link_for_hyprlock(wallpaper)
        launch_sddm_update(wallpaper)  # async — runs in its own kitty window
        generate_palette(wallpaper)  # blocking — refresh needs the new colors
    except Exception as e:
        subprocess.run(
            [
                "notify-send",
                "-u",
                "critical",
                "󰏘 Theme Not Applied",
                f"Failed to apply wallpaper: {e}",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        sys.exit(1)

    # Full session refresh (waybar + swaync + hyprland)
    log("INFO", "Wallpaper changed, triggering full session refresh")
    refresh.main()


if __name__ == "__main__":
    main()
