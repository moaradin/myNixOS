# 1. Get the focused window's App ID
APP_NAME=$(niri msg --json focused-window | jq -r '.app_id // "Unknown"')

# 2. Define your source and destination directories
SOURCE_DIR="/home/moara/Pictures/Screenshots"
DEST_BASE_DIR="/home/moara/Pictures/Niri/$APP_NAME"

# Create the destination subdirectory if it doesn't exist
mkdir -p "$DEST_BASE_DIR"

# 3. Record the current newest file to detect when Niri creates the new one
OLD_LATEST=$(ls -t "$SOURCE_DIR"/*.png 2>/dev/null | head -1)

# 4. Trigger the screenshot
niri msg action screenshot-screen

# 5. Wait for the new screenshot to appear (with a 10-second timeout to prevent infinite loops)
TIMEOUT=20
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
  NEW_LATEST=$(ls -t "$SOURCE_DIR"/*.png 2>/dev/null | head -1)

  # If the newest file is different from what we recorded before, the new screenshot is ready!
  if [ "$NEW_LATEST" != "$OLD_LATEST" ] && [ -n "$NEW_LATEST" ]; then
    # Wait a tiny fraction of a second to ensure Niri is completely done writing the file
    sleep 0.2
    mv "$NEW_LATEST" "$DEST_BASE_DIR/"
    exit 0
  fi

  # Check every 0.5 seconds
  sleep 0.5
  ELAPSED=$((ELAPSED + 1))
done

echo "Error: Screenshot creation timed out."
