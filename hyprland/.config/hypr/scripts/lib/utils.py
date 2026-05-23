"""Shared utilities for Hyprland Python scripts"""

import subprocess
from datetime import datetime
from pathlib import Path

# Paths
# ------------------------------------------------------------------------------

LOG_FILE = Path.home() / ".local/state/hypr/refresh.log"
MAX_LOG_SIZE = 1_048_576  # 1 MB

# Ensure the log directory exists at import time so callers never have to
# think about it.
LOG_FILE.parent.mkdir(parents=True, exist_ok=True)

# Logging
# ------------------------------------------------------------------------------


def log(level: str, message: str) -> None:
    """Append a timestamped entry to the Hyprland refresh log."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    entry = f"[{timestamp}] [{level}] {message}\n"
    # Append mode: each call is its own open/close so concurrent scripts
    # don't interleave writes inside a single buffered write call.
    with LOG_FILE.open("a") as f:
        f.write(entry)


def rotate_log() -> None:
    """Rotate the log file if it exceeds MAX_LOG_SIZE."""
    if LOG_FILE.exists() and LOG_FILE.stat().st_size > MAX_LOG_SIZE:
        LOG_FILE.rename(LOG_FILE.with_suffix(".log.old"))
        log("INFO", "Log rotated due to size")


# Process helpers
# ------------------------------------------------------------------------------


def is_running(process_name: str) -> bool:
    """Return True if a process with the exact name is running."""
    result = subprocess.run(["pgrep", "-x", process_name], capture_output=True)
    return result.returncode == 0
