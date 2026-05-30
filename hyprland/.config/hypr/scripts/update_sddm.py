"""Update SDDM background wallpaper."""

import subprocess
import sys
from pathlib import Path

SDDM_THEME_NAME = "sddm-astronaut-theme"
SDDM_THEME_DIR = Path(f"/usr/share/sddm/themes/{SDDM_THEME_NAME}")
SDDM_BG = Path(f"{SDDM_THEME_DIR}/current_wallpaper")


def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: update_sddm.py <wallpaper_path>", file=sys.stderr)
        sys.exit(1)

    wallpaper = Path(sys.argv[1])

    print("Updating SDDM background...")
    print(f"Wallpaper: {wallpaper}")

    # Run the three sudo operations as a sequence, stopping on first failure.
    steps = [
        (["sudo", "cp", str(wallpaper), str(SDDM_BG)], "copy wallpaper"),
        (["sudo", "chmod", "644", str(SDDM_BG)], "set permissions"),
        (["sudo", "chown", "root:root", str(SDDM_BG)], "set ownership"),
    ]

    for cmd, description in steps:
        result = subprocess.run(cmd)
        if result.returncode != 0:
            print(f"Failed to {description}.")
            print("SDDM background update failed.")
            input("\nPress Enter to close...")
            sys.exit(1)

    print("SDDM background updated successfully!")
    input("\nPress Enter to close...")


if __name__ == "__main__":
    main()
