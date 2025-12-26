#!/usr/bin/env bash

# ┌───────────────────────────────────────────────────────────────────────────┐
# │                      NOTIFICATION SYSTEM TEST                             │
# └───────────────────────────────────────────────────────────────────────────┘
# Tests all notification types with Dracula theme

echo "Testing Dracula-themed notifications..."
echo ""

# Test 1: Low urgency notification
echo "1. Testing low urgency notification..."
notify-send -u low "Low Priority" "This is a low priority notification with gray border"
sleep 2

# Test 2: Normal urgency notification
echo "2. Testing normal urgency notification..."
notify-send -u normal "Normal Priority" "This is a normal notification with purple border"
sleep 2

# Test 3: Critical urgency notification
echo "3. Testing critical urgency notification..."
notify-send -u critical "Critical Alert" "This is a critical notification with red background"
sleep 2

# Test 4: Color picker notification (simulated)
echo "4. Testing color picker notification..."
COLOR="#BD93F9"
TEMP_IMG="/tmp/test_color_preview.png"
magick -size 128x128 "xc:$COLOR" "$TEMP_IMG"
notify-send -a "color-picker" -u low -i "$TEMP_IMG" "Color Copied" "<b>$COLOR</b>\n\nCopied to clipboard" -t 5000
rm -f "$TEMP_IMG"
sleep 2

# Test 5: Screenshot notification (simulated)
echo "5. Testing screenshot notification..."
notify-send -a "screenshot" -u normal "Screenshot Saved" "screenshot-test.png\n\n~/Pictures/screenshots/" -t 5000
sleep 2

# Test 6: Telegram-style notification
echo "6. Testing Telegram notification..."
notify-send -a "telegram" -u normal "Telegram" "New message from Test User\n\nHello! This is a test message." -t 8000
sleep 2

# Test 7: Progress bar notification
echo "7. Testing progress bar notification..."
notify-send -u normal -h int:value:75 "Download Progress" "Downloading file... 75%"
sleep 2

echo ""
echo "✓ Notification test complete!"
echo "All notifications should have appeared with Dracula theme colors:"
echo "  • Purple borders for normal notifications"
echo "  • Gray borders for low priority"
echo "  • Red background for critical"
echo "  • Green border for screenshots"
echo "  • Cyan border for color picker and Telegram"
