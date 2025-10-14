#!/usr/bin/bash


set -Eeuo pipefail
trap 'print_error "Unexpected error occurred at line $LINENO"; exit 1' ERR

# Configuration
CACHE_DIR="$HOME/.cache"
CONFIG_DIR="$HOME/.config/cache-cleanup"
MAPPINGS_FILE="$CONFIG_DIR/mappings.conf"

# Create default mappings config if it doesn't exist
create_default_config() {
    if [[ -f "$MAPPINGS_FILE" ]]; then
        return 0
    fi

    print_info "Creating default mappings configuration..."

    mkdir -p "$CONFIG_DIR"

    cat > "$MAPPINGS_FILE" << 'EOF'
# Cache Cleanup Mappings Configuration
# Format: package_name:cache_directory_name
#
# This file maps package names to their cache directories in ~/.cache
# When a package is uninstalled, its cache directory will be cleaned up
#
# Examples:
#   discord:discord
#   visual-studio-code-bin:Code
#   slack-desktop:Slack
#
# You can add your own mappings below:

# Communication apps
discord:discord
slack-desktop:Slack
telegram-desktop:telegram-desktop
zoom:zoom

# Browsers (note: these are in exclude list, but mapping for reference)
# firefox:mozilla
# google-chrome:google-chrome
# chromium:chromium

# Development tools
visual-studio-code-bin:Code
visual-studio-code-bin:vscode
jetbrains-toolbox:JetBrains

# Media apps
spotify:spotify
vlc:vlc

# Electron apps (common pattern)
obsidian:obsidian
notion-app:Notion

# Add your custom mappings below this line:

EOF

    print_success "Default config created at: $MAPPINGS_FILE"
    log "INFO" "Created default mappings config"
}

# Load package-to-cache mappings from config
load_mappings() {
    local -n mappings_ref=$1

    if [[ ! -f "$MAPPINGS_FILE" ]]; then
        print_warning "Mappings file not found: $MAPPINGS_FILE"
        return 0
    fi

    while IFS=':' read -r package cache_dir; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue

        # Trim whitespace
        package=$(echo "$package" | xargs)
        cache_dir=$(echo "$cache_dir" | xargs)

        [[ -z "$package" || -z "$cache_dir" ]] && continue

        mappings_ref["$package"]="$cache_dir"
    done < "$MAPPINGS_FILE"

    log "INFO" "Loaded ${#mappings_ref[@]} package-to-cache mappings"
}

# Get list of directories to exclude from cleanup
get_excluded_dirs() {
    cat << 'EOF'
paru
mozilla
BraveSoftware
firefox
floorp
pip
fontconfig
thumbnails
mesa_shader_cache
mesa_shader_cache_db
radv_builtin_shaders
nvidia
AMD
pkgfile
zen
.pk2
EOF
}
