import re
import yaml
import subprocess
import sys
from pathlib import Path
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.columns import Columns
from rich.text import Text
from rich import box
from typing import Dict


class KeybindReference:
    def __init__(self):
        self.descriptions = None
        self.categories = None
        self.console = Console()
        self.hypr_config = Path.home() / ".config/hypr"
        self.descriptions_file = (
            self.hypr_config / "scripts/resources/keybind_descriptions.yaml"
        )
        self.keybind_files = [
            self.hypr_config / "keybinds/apps.conf",
            self.hypr_config / "keybinds/hypr.conf",
            self.hypr_config / "keybinds/workspaces.conf",
        ]

        # Initialize key mappings
        self.key_mappings = self._create_key_mappings()

        # Load descriptions and config
        self.load_descriptions()
        self.keybinds = self.parse_keybinds()

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

    def load_descriptions(self):
        """Load descriptions from YAML file"""
        try:
            with open(self.descriptions_file, "r") as f:
                data = yaml.safe_load(f)
                self.categories = data.get("categories", {})
                self.descriptions = data.get("descriptions", {})
        except FileNotFoundError:
            self.console.print("[red]Error: keybind_descriptions.yaml not found![/red]")
            sys.exit(1)

    def parse_keybinds(self) -> Dict[str, list[Dict]]:
        """Parse keybinds from config files"""
        keybinds_by_category = {cat: [] for cat in self.categories.keys()}

        # Mapping from filename to category
        file_to_category = {
            "apps.conf": "Applications",
            "hypr.conf": "Desktop",
            "workspaces.conf": "Workspaces",
        }

        for config_file in self.keybind_files:
            if not config_file.exists():
                continue

            category = file_to_category.get(config_file.name, "Other")
            if category not in keybinds_by_category:
                keybinds_by_category[category] = []

            with open(config_file, "r") as f:
                content = f.read()

            # Parse different bind types
            patterns = [
                r"bind\s*=\s*([^,]+),\s*([^,]+),\s*(.+)",
                r"binde\s*=\s*([^,]+),\s*([^,]+),\s*(.+)",
                r"bindm\s*=\s*([^,]+),\s*([^,]+),\s*(.+)",
            ]

            for pattern in patterns:
                matches = re.findall(pattern, content)
                for modifier, key, action in matches:
                    # Replace $mainMod with SUPER
                    modifier = modifier.strip().replace("$mainMod", "")
                    key = key.strip()
                    action = action.strip()

                    # Format the key using our mapping
                    formatted_key = self._format_key(key)

                    # Create keybind string and get description
                    keybind_str = (
                        f"{modifier} + {formatted_key}"
                        if modifier != ""
                        else f" + {formatted_key}"
                    )
                    description = self.descriptions.get(action, action)

                    keybinds_by_category[category].append(
                        {
                            "keybind": keybind_str,
                            "action": action,
                            "description": description,
                        }
                    )

        return keybinds_by_category

    def show_tui(self):
        """Display rich TUI"""
        self.console.clear()

        # Title
        title = Text(
            "Hyprland Keybind Reference", style="bold magenta", justify="center"
        )
        self.console.print(Panel(title, box=box.DOUBLE))
        self.console.print()

        # Create tables for each category
        tables = []
        for category, binds in self.keybinds.items():
            if not binds:
                continue

            cat_info = self.categories.get(category, {})
            icon = cat_info.get("icon", "📝")
            color = cat_info.get("color", "white")

            table = Table(
                title=f"{icon} {category}", box=box.ROUNDED, title_style=f"bold {color}"
            )
            table.add_column("Keybind", style="cyan", width=20)
            table.add_column("Description", style="white")

            for bind in binds:
                table.add_row(bind["keybind"], bind["description"])

            tables.append(table)

        # Display in columns
        self.console.print(Columns(tables, equal=True, expand=True))

        # Footer
        footer = Text(
            "\nPress 'q' to quit, 'r' for rofi mode", style="dim", justify="center"
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
        rofi_entries = []

        # Define color scheme (Catppuccin-inspired)
        colors = {
            "Applications": "#89dceb",  # Cyan
            "Desktop": "#a6e3a1",  # Green
            "Workspaces": "#cba6f7",  # Magenta
        }

        # Description color scheme (analogous colors)
        colors_desc = {
            "Applications": "#89abeb",
            "Desktop": "#a1e3bc",
            "Workspaces": "#f3a6f7",
        }

        # Seperator color scheme (complementary colors)
        colors_sep = {
            "Applications": "#eb9889",
            "Desktop": "#dda1e3",
            "Workspaces": "#d3f7a6",
        }

        for category, binds in self.keybinds.items():
            if not binds:
                continue

            cat_info = self.categories.get(category, {})
            icon = cat_info.get("icon", "📝")
            category_color = colors.get(category, "#cdd6f4")
            seperator_color = colors_sep.get(category, "#f4ebcd")
            description_color = colors_desc.get(category, "#cdeaf4")

            # Styled category header with background
            header = f"<span background='{category_color}' foreground='#1e1e2e' weight='bold' size='large'> {icon} {category.upper()} </span>"
            rofi_entries.append(header)
            rofi_entries.append(
                f"<span foreground='{seperator_color}'>{'─' * 100}</span>"
            )  # Spacing after header

            # Add keybinds
            for bind in binds:
                # Format: [KEYBIND] │ Description
                keybind_part = f"<span foreground='{category_color}' weight='bold'>{bind['keybind']:<25}</span>"
                separator = f"<span foreground='{seperator_color}'>│</span>"
                desc_part = f"<span foreground='{description_color}'>{bind['description']}</span>"

                entry = f"{keybind_part} {separator} {desc_part}"
                rofi_entries.append(entry)

            # Category separator
            rofi_entries.append(
                f"<span foreground='{seperator_color}'>{'─' * 100}</span>"
            )
            rofi_entries.append("")  # Separator

        # Create rofi command
        rofi_input = "\n".join(rofi_entries)
        cmd = [
            "rofi",
            "-dmenu",
            "-mesg",
            "<span foreground='#17d7e8' weight='bold'> Hyprland Keybind Reference</span>",
            "-i",  # Case-insensitive
            "-theme-str",
            "window { width: 75%; height: 75%; }",
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
