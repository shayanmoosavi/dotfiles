"""Shared utilities for Hyprland Python scripts"""

import subprocess
from datetime import datetime
from pathlib import Path
import re

# Paths
# ------------------------------------------------------------------------------------------------------------------------------

LOG_FILE = Path.home() / ".local/state/hypr/refresh.log"
MAX_LOG_SIZE = 1_048_576  # 1 MB

# Ensure the log directory exists at import time so callers never have to think about it.
LOG_FILE.parent.mkdir(parents=True, exist_ok=True)

# Path to the defaults.lua file, used by launcher.py and other scripts that need to read/write default module settings.
_DEFAULTS = Path.home() / ".config/hypr/modules/keybinds/defaults.lua"

# Logging
# ------------------------------------------------------------------------------------------------------------------------------


def log(level: str, message: str) -> None:
    """Append a timestamped entry to the Hyprland refresh log."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    entry = f"[{timestamp}] [{level}] {message}\n"
    # Append mode: each call is its own open/close so concurrent scripts don't interleave writes inside a single
    # buffered write call.
    with LOG_FILE.open("a") as f:
        f.write(entry)


def rotate_log() -> None:
    """Rotate the log file if it exceeds MAX_LOG_SIZE."""
    if LOG_FILE.exists() and LOG_FILE.stat().st_size > MAX_LOG_SIZE:
        LOG_FILE.rename(LOG_FILE.with_suffix(".log.old"))
        log("INFO", "Log rotated due to size")


# Process helpers
# ------------------------------------------------------------------------------------------------------------------------------


def is_running(process_name: str) -> bool:
    """Return True if a process with the exact name is running."""
    result = subprocess.run(["pgrep", "-x", process_name], capture_output=True)
    return result.returncode == 0


# Default application resolver
# ------------------------------------------------------------------------------------------------------------------------------

_APP_MAP: dict[str, tuple[str, str]] = {
    "browser": ("Browser", "firefox"),
    "file-manager": ("FileManager", "thunar"),
    "terminal": ("Terminal", "kitty"),
}


def get_default_app(app_type: str) -> str:
    """
    Gets the configured default app for the given type, or its fallback.

    Args:
        app_type (str): One of "browser", "file-manager", or "terminal".

    Returns:
        str: The command for the default app, or the fallback if not set.

    Raises:
        ValueError: For unknown types so callers fail loudly.
    """
    if app_type not in _APP_MAP:
        raise ValueError(f"Unknown application type: {app_type!r}")

    var_name, fallback = _APP_MAP[app_type]

    # Parse the whole table once per call
    defaults = _parse_defaults_lua()
    return defaults.get(var_name) or fallback


def _parse_defaults_lua() -> dict[str, str]:
    """
    Parse the key = "value" pairs out of defaults.lua.

    Returns:
        dict[str, str]: A dictionary of the parsed key-value pairs.
    """
    if not _DEFAULTS.exists():
        return {}

    content = _DEFAULTS.read_text()
    # Captures:  key    =   "value"  or  'value'
    pairs = re.findall(r'(\w+)\s*=\s*["\']([a-zA-Z]*)["\']', content)

    parsed = dict(pairs)
    if "MainMod" in parsed:
        # Not an app, just a modifier key that happens to be in the same file.
        parsed.pop("MainMod")

    return parsed
