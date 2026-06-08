import json
import subprocess
import sys
from dataclasses import field
from pathlib import Path

from rich import box
from rich.columns import Columns
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.text import Text


class KeybindReference:
    def __init__(self):
        self.console = Console()
        self.hypr_config = Path.home() / ".config/hypr"
        self.colors_path = self.hypr_config / "scripts/resources/keybind-colors.json"

        # Initialize key mappings
        self.key_mappings = self._create_key_mappings()

        # Load descriptions and config
        self.global_colors = field(default_factory=dict)
        self.keybinds = self._load_keybinds()

    @staticmethod
    def _create_key_mappings() -> dict:
        """Create mapping of Hyprland key codes to user-friendly representations"""
        return {
            # Mouse buttons
            "mouse:272": " Left Click",
            "mouse:273": " Right Click",
            "mouse:274": " Middle Click",
            "mouse:275": " Side Button 1",
            "mouse:276": " Side Button 2",
            # Number row (code:X format)
            "code:10": "1",
            "code:11": "2",
            "code:12": "3",
            "code:13": "4",
            "code:14": "5",
            "code:15": "6",
            "code:16": "7",
            "code:17": "8",
            "code:18": "9",
            "code:19": "0",
            # Special characters
            "bracketleft": "[",
            "bracketright": "]",
            "semicolon": ";",
            "apostrophe": "'",
            "grave": "`",
            "backslash": "\\",
            "comma": ",",
            "period": ".",
            "slash": "/",
            "minus": "-",
            "equal": "=",
            # Special function keys
            "XF86AudioRaiseVolume": "󰝝",
            "XF86AudioLowerVolume": "󰝞",
            "XF86AudioMute": "󰸈",
            "XF86MonBrightnessUp": "󰃠 󰐕",
            "XF86MonBrightnessDown": "󰃠 󰍴",
            # Arrow keys
            "left": "←",
            "right": "→",
            "up": "↑",
            "down": "↓",
            # Editing keys
            "Return": "↵ Enter",
            "KP_Enter": "↵ Enter (Numpad)",
            "BackSpace": "⌫ Backspace",
            "Escape": "󱊷 Esc",
            "Space": "␣ Space",
            # SUPER key
            "SUPER": "",
        }

    def _format_key(self, key: str) -> str:
        """Convert a key code to user-friendly representation"""
        # Check if it's in our mappings
        if key in self.key_mappings:
            return self.key_mappings[key]

        # Handle case where it's already user-friendly
        # Just capitalize first letter for consistency
        if len(key) == 1:
            return key.upper()

        # For unmapped keys, return as-is
        return key

    def _format_key_combo(self, combo: str) -> str:
        """Formats a key combo string by replacing key codes with user-friendly representations"""
        return " + ".join(self._format_key(part.strip()) for part in combo.split(" + "))

    def _load_colors(self) -> dict:
        """Read the matugen-generated color file. Warns and returns empty dict if missing."""
        if not self.colors_path.exists():
            self.console.print(
                "[yellow]Warning:[/yellow] keybind_colors.json not found — "
                "run matugen to generate it. Falling back to plain colors."
            )
            return {}
        return json.loads(self.colors_path.read_text())

    def _load_keybinds(self) -> list[dict]:
        """Loads the keybinds from keybinds.json, and format key combos for display."""
        keybinds_path = self.hypr_config / "scripts/resources/keybinds.json"
        if not keybinds_path.exists():
            self.console.print(
                f"[red]Error:[/red] keybinds.json not found at {keybinds_path}. "
                "Reload your Hyprland config to generate it."
            )
            sys.exit(1)

        keybinds = json.loads(keybinds_path.read_text())
        colors = self._load_colors()

        # Store global colors so show_tui / show_rofi can use them without re-reading
        self.global_colors = colors.get("global", {})
        section_colors: dict = colors.get("sections", {})

        # Format key combos in-place so both UI modes see friendly strings
        for section in keybinds:
            section_color = section_colors.get(section["section"], {})
            # Fall back gracefully: color_desc → color, color_sep → color if not specified
            section["color"] = section_color.get("color", "#ffffff")
            section["color_desc"] = section_color.get("color_desc", section["color"])
            section["color_sep"] = section_color.get("color_sep", section["color"])

            for bind in section["binds"]:
                bind["key"] = self._format_key_combo(bind["key"])

        return keybinds

    def show_tui(self):
        """Display rich TUI"""
        self.console.clear()

        accent = self.global_colors.get("title_bg", "magenta")
        muted = self.global_colors.get("muted", "dim")

        # Title
        title = Text(
            " Hyprland Keybind Reference", style=f"bold {accent}", justify="center"
        )
        self.console.print(Panel(title, box=box.DOUBLE))
        self.console.print()

        # Create tables for each category
        tables = []
        for section in self.keybinds:
            if not section["binds"]:
                continue

            table = Table(
                title=f"{section['icon']} {section['section']}",
                box=box.ROUNDED,
                title_style=f"bold {section['color']}",
                style=f"{section['color_sep']}",
            )
            table.add_column("Keybind", style=section["color"], width=24)
            table.add_column("Description", style=section["color_desc"])

            for bind in section["binds"]:
                table.add_row(bind["key"], bind["description"])

            tables.append(table)

        self.console.print(Columns(tables, equal=True, expand=True))

        # Footer
        footer = Text(
            "\nPress 'q' to quit, 'r' for rofi mode", style=muted, justify="center"
        )
        self.console.print(Panel(footer, box=box.SIMPLE))

        # Wait for input
        try:
            key = input()
            if key.lower() == "r":
                self.show_rofi()
        except KeyboardInterrupt:
            pass

    def show_rofi(self):
        """Display rofi interface"""
        # Prepare rofi data
        bg = self.global_colors.get("background", "#1c100f")
        title_clr = self.global_colors.get("title_bg", "#ffb4ab")
        header_fg = self.global_colors.get("header_fg", bg)

        rofi_entries = []

        for section in self.keybinds:
            if not section["binds"]:
                continue

            # Define color scheme
            color = section["color"]
            color_desc = section.get("color_desc", color)
            color_sep = section.get("color_sep", color)

            header = (
                f"<span background='{color}' foreground='{header_fg}' "
                f"weight='bold' size='large'> {section['icon']} {section['section'].upper()} </span>"
            )
            rofi_entries.append(header)
            rofi_entries.append(f"<span foreground='{color_sep}'>{'─' * 100}</span>")

            for bind in section["binds"]:
                keybind_part = f"<span foreground='{color}'      weight='bold'>{bind['key']:<25}</span>"
                separator = f"<span foreground='{color_sep}'>│</span>"
                desc_part = (
                    f"<span foreground='{color_desc}'>{bind['description']}</span>"
                )
                rofi_entries.append(f"{keybind_part} {separator} {desc_part}")

            rofi_entries.append(f"<span foreground='{color_sep}'>{'─' * 100}</span>")
            rofi_entries.append("")

        # Create rofi command
        rofi_input = "\n".join(rofi_entries)
        cmd = [
            "rofi",
            "-dmenu",
            "-mesg",
            f"<span foreground='{title_clr}' weight='bold'> Hyprland Keybind Reference</span>",
            "-i",  # Case-insensitive
            "-theme-str",
            f"window {{ width: 75%; height: 75%; background-color: {bg};}}",
            "-theme-str",
            "listview { lines: 20; columns: 1; }",
            "-markup-rows",
            "-no-custom",  # Disable custom entries
        ]

        try:
            subprocess.run(cmd, input=rofi_input, text=True, check=False)
        except FileNotFoundError:
            self.console.print("[red]Error: rofi not found![/red]")


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--rofi":
        KeybindReference().show_rofi()
    else:
        KeybindReference().show_tui()


if __name__ == "__main__":
    main()
