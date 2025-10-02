#!/usr/bin/bash

# Rofi version
if [[ "$1" == "--tui" ]]; then
    kitty --title="Keybinds Reference" -e python3 ~/.config/hypr/scripts/keybinds_reference.py
# TUI version (default)
else
    python3 ~/.config/hypr/scripts/keybinds_reference.py --rofi
fi