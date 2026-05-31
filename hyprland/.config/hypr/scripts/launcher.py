"""Launcher script for Hyprland.

Launches the default app for a given type, or a fallback if not set.
Types are defined in _APP_MAP and currently include "browser", "file-manager", and "terminal".
The configured defaults are read from a Lua file, and the script falls back to hardcoded defaults
if not set or if the file is missing.
"""

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from lib.utils import get_default_app

# Maps CLI flags to the app_type keys get_default_app() understands.
APP_FLAGS: dict[str, str] = {
    "--browser": "browser",
    "--file-manager": "file-manager",
    "--terminal": "terminal",
}


def show_usage() -> None:
    """Displays the usage of the script."""
    print(
        "Usage: launcher.py [--browser|--file-manager|--terminal] [additional_args...]",
        file=sys.stderr,
    )
    print("", file=sys.stderr)
    print("Examples:", file=sys.stderr)
    print("  launcher.py --browser", file=sys.stderr)
    print("  launcher.py --browser --new-tab https://google.com", file=sys.stderr)
    print("  launcher.py --file-manager ~/Downloads", file=sys.stderr)
    print("  launcher.py --terminal --hold -e htop", file=sys.stderr)


def validate_arguments() -> str:
    """
    Validates the provided arguments.

    Returns:
        str: The validated argument.
    """
    if len(sys.argv) < 2:
        print("Error: No arguments provided", file=sys.stderr)
        show_usage()
        sys.exit(1)

    flag = sys.argv[1]

    if flag in ("--help", "-h"):
        show_usage()
        sys.exit(0)

    if flag not in APP_FLAGS:
        print(f"Error: Unknown option {flag!r}", file=sys.stderr)
        show_usage()
        sys.exit(1)

    return flag


def main() -> None:
    flag = validate_arguments()

    try:
        app = get_default_app(APP_FLAGS[flag])
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    if not app:
        print(f"Error: Could not determine application for {flag}", file=sys.stderr)
        sys.exit(1)

    extra_args = sys.argv[2:]

    # Replaces this process with the target app entirely. The launched app
    # becomes the process rather than a child of it, so the Python runtime
    # doesn't linger as a parent. The first argument is the argv[0] the
    # program sees as its own name, conventionally the binary name itself.
    os.execvp(app, [app] + extra_args)


if __name__ == "__main__":
    main()
