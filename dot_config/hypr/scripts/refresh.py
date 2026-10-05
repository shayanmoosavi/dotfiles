"""Refresh module for Hyprland.

Provides functions to refresh various Hyprland components: waybar, swaync, and hyprland itself.
"""

import subprocess
import sys
from pathlib import Path

# Make `from lib.utils import ...` work whether this file is run directly
# or imported by another script in the same directory.
sys.path.insert(0, str(Path(__file__).parent))
from lib.utils import LOG_FILE, is_running, log, rotate_log


def refresh_waybar() -> bool:
    """
    Refreshes the Waybar by sending a SIGUSR2 signal or starting it if not running.

    Returns:
        bool: True if refresh was successful, False otherwise.
    """
    if is_running("waybar"):
        log("INFO", "Refreshing waybar")
        result = subprocess.run(["killall", "-SIGUSR2", "waybar"], capture_output=True)
        if result.returncode == 0:
            log("INFO", "Waybar refreshed successfully")
            return True
        else:
            log("ERROR", "Failed to refresh waybar")
            return False
    else:
        log("WARN", "Waybar not running, attempting to start")
        # Popen (non-blocking) + start_new_session=True replicates `waybar &`.
        # start_new_session detaches waybar from this process so it keeps
        # running after this script exits.
        subprocess.Popen(
            ["waybar"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
        log("INFO", "Waybar started successfully")
        return True


def refresh_swaync() -> bool:
    """
    Refreshes the Swaync notification center.

    Returns:
        bool: True if refresh was successful, False otherwise.
    """
    if is_running("swaync"):
        log("INFO", "Refreshing swaync")
        config_ok = _run("swaync config reload", ["swaync-client", "--reload-config"])
        css_ok = _run("swaync CSS reload", ["swaync-client", "--reload-css"])

        if config_ok and css_ok:
            log("INFO", "Swaync refreshed successfully")
            return True
        return False
    else:
        log("WARN", "Swaync not running, attempting to start")
        subprocess.Popen(
            ["swaync"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
        log("INFO", "Swaync started successfully")
        return True


def refresh_hyprland() -> bool:
    """
    Refreshes the Hyprland configuration.

    Returns:
        bool: True if refresh was successful, False otherwise.
    """
    log("INFO", "Refreshing Hyprland configuration")
    return _run("Hyprland config reload", ["hyprctl", "reload"])


# Internal helper
# ------------------------------------------------------------------------------


def _run(label: str, cmd: list[str]) -> bool:
    """
    Run a command, log any stderr output, and return True on success.

    Returns:
        bool: True if the command succeeded, False otherwise.
    """
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        stderr = result.stderr.strip()
        detail = f": {stderr}" if stderr else ""
        log("ERROR", f"Failed — {label}{detail}")
        return False
    return True


# Entry point
# ------------------------------------------------------------------------------


def main() -> None:
    rotate_log()
    log("INFO", "Starting Hyprland session refresh")

    failed: list[str] = []

    if not refresh_waybar():
        failed.append("Waybar")
    if not refresh_swaync():
        failed.append("Swaync")
    if not refresh_hyprland():
        failed.append("Hyprland")

    if not failed:
        log("INFO", "All components refreshed successfully")
    else:
        failed_list = ", ".join(failed)
        log("ERROR", f"Some components failed to refresh: {failed_list}")
        subprocess.run(
            [
                "notify-send",
                "-u",
                "critical",
                "Refresh Failed",
                f"Failed components: {failed_list}\nCheck log: {LOG_FILE}",
            ]
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
