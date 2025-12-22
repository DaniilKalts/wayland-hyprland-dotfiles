#!/usr/bin/env bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗  █████╗ ██████╗ ███████╗██████╗ ║
# ║  ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗║
# ║  ██║ █╗ ██║███████║██║     ██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝║
# ║  ██║███╗██║██╔══██║██║     ██║     ██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗║
# ║  ╚███╔███╔╝██║  ██║███████╗███████╗██║     ██║  ██║██║     ███████╗██║  ██║║
# ║   ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝║
# ║                                                                            ║
# ║  ███████╗███████╗██╗     ███████╗ ██████╗████████╗ ██████╗ ██████╗         ║
# ║  ██╔════╝██╔════╝██║     ██╔════╝██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗        ║
# ║  ███████╗█████╗  ██║     █████╗  ██║        ██║   ██║   ██║██████╔╝        ║
# ║  ╚════██║██╔══╝  ██║     ██╔══╝  ██║        ██║   ██║   ██║██╔══██╗        ║
# ║  ███████║███████╗███████╗███████╗╚██████╗   ██║   ╚██████╔╝██║  ██║        ║
# ║  ╚══════╝╚══════╝╚══════╝╚══════╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝        ║
# ║                      Wayland/Hyprland Version                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Check for required commands
for cmd in magick swaybg wofi notify-send; do
    if ! command -v "$cmd" &> /dev/null; then
        case "$cmd" in
            magick) pkg_name="imagemagick" ;;
            *) pkg_name="$cmd" ;;
        esac
        echo "Missing: $pkg_name" >&2
        exit 1
    fi
done

# Configuration
WALL_DIR="$HOME/wallpapers"
CACHE_DIR="$HOME/.cache/wallpapers"
CURRENT_WALL="$HOME/.cache/current_wallpaper"

# Create directories if they don't exist
mkdir -p "$CACHE_DIR"

# Check if wallpaper directory exists
if [[ ! -d "$WALL_DIR" ]]; then
    notify-send "Error" "Wallpaper directory not found: $WALL_DIR" -u critical
    exit 1
fi

# Generate thumbnails for wofi
generate_thumbnails() {
    for img in "$WALL_DIR"/*.{jpg,jpeg,png,webp} 2>/dev/null; do
        [[ -f "$img" ]] || continue
        filename=$(basename "$img")
        thumb="$CACHE_DIR/$filename"

        # Generate thumbnail if it doesn't exist or is older than source
        if [[ ! -f "$thumb" ]] || [[ "$img" -nt "$thumb" ]]; then
            magick "$img" -resize 200x200^ -gravity center -extent 200x200 "$thumb" 2>/dev/null
        fi
    done
}

# Generate thumbnails
generate_thumbnails

# Build the list for wofi with icons
build_list() {
    for img in "$WALL_DIR"/*.{jpg,jpeg,png,webp} 2>/dev/null; do
        [[ -f "$img" ]] || continue
        filename=$(basename "$img")
        thumb="$CACHE_DIR/$filename"

        if [[ -f "$thumb" ]]; then
            echo -e "img:$thumb:text:$filename"
        else
            echo "$filename"
        fi
    done | sort
}

# Show wofi menu
selection=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | wofi --dmenu \
    --prompt "Select Wallpaper" \
    --conf /dev/null \
    --style "$HOME/.config/wofi/style.css" \
    --width 400 \
    --lines 10 \
    --cache-file /dev/null \
    --normal-window)

# Set wallpaper if selection was made
if [[ -n "$selection" ]]; then
    wallpaper="$WALL_DIR/$selection"

    if [[ -f "$wallpaper" ]]; then
        # Kill existing swaybg instance
        pkill swaybg 2>/dev/null

        # Set new wallpaper
        swaybg -i "$wallpaper" -m fill &

        # Save current wallpaper path for persistence
        echo "$wallpaper" > "$CURRENT_WALL"

        # Update hyprland.conf autostart (optional - for persistence across reboots)
        # This updates the swaybg line in hyprland.conf
        HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
        if [[ -f "$HYPR_CONF" ]]; then
            sed -i "s|exec-once = swaybg -i .* -m fill|exec-once = swaybg -i $wallpaper -m fill|g" "$HYPR_CONF"
        fi

        notify-send "Wallpaper Changed" "$(basename "$wallpaper")" -i "$wallpaper"
    else
        notify-send "Error" "Wallpaper file not found: $wallpaper" -u critical
    fi
fi
