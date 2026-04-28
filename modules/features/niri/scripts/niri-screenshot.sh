# 1. Get the focused window's App ID
WINDOW_JSON=$(niri msg --json focused-window)
APP_NAME=$(echo "$WINDOW_JSON" | jq -r '.app_id // "Unknown"')

# Debug log — remove once confirmed working
echo "$(date): window_json=$WINDOW_JSON app_name=$APP_NAME" >>/tmp/niri-screenshot-debug.log

# 2. Define your source and destination directories
SOURCE_DIR="/home/moara/Pictures/Screenshots"
DEST_BASE_DIR="/home/moara/Pictures/Niri/$APP_NAME"

# Create the destination subdirectory if it doesn't exist
mkdir -p "$DEST_BASE_DIR"

# 3. Record the current newest file to detect when Niri creates the new one
OLD_LATEST=$(find "$SOURCE_DIR" -maxdepth 1 -name "*.png" -printf "%T@ %p\n" 2>/dev/null |
  sort -rn | head -1 | cut -d' ' -f2- || true)

# 4. Trigger a screenshot
niri msg action screenshot-screen

# 5. Wait for the new screenshot to appear (with a 10-second timeout)
TIMEOUT=20
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
  NEW_LATEST=$(find "$SOURCE_DIR" -maxdepth 1 -name "*.png" -printf "%T@ %p\n" 2>/dev/null |
    sort -rn | head -1 | cut -d' ' -f2- || true)

  if [ "$NEW_LATEST" != "$OLD_LATEST" ] && [ -n "$NEW_LATEST" ]; then
    sleep 0.2
    mv "$NEW_LATEST" "$DEST_BASE_DIR/"
    echo "$(date): moved $NEW_LATEST -> $DEST_BASE_DIR/" >>/tmp/niri-screenshot-debug.log
    exit 0
  fi

  sleep 0.5
  ELAPSED=$((ELAPSED + 1))
done

echo "$(date): timed out waiting for screenshot" >>/tmp/niri-screenshot-debug.log
exit 1
