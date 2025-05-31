#!/bin/bash

# 1. Check input
INPUT="$1"
if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 your-image.png"
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "File not found: $INPUT"
  exit 1
fi

# 2. Get image dimensions
read WIDTH HEIGHT <<< $(identify -format "%w %h" "$INPUT")

if [[ "$WIDTH" -ne "$HEIGHT" ]]; then
  echo "Error: Image must be square (got ${WIDTH}x${HEIGHT})"
  exit 1
fi

if [[ "$WIDTH" -lt 1024 ]]; then
  echo "Error: Image must be at least 1024×1024"
  exit 1
fi

# 3. Trim whitespace and resize to 1024x1024
TRIMMED="icon_trimmed.png"
RESIZED="icon1024.png"
FILENAME="${INPUT##*/}"         # strips path → "logo.png"
BASENAME="${FILENAME%.*}"       # strips extension → "logo"

convert "$INPUT" -trim +repage "$TRIMMED"
convert "$TRIMMED" -resize 1024x1024 "$RESIZED"

# 4. Generate .appiconset
mkdir -p AppIcon.appiconset
convert "$RESIZED" -resize 16x16   AppIcon.appiconset/icon_16x16.png
convert "$RESIZED" -resize 32x32   AppIcon.appiconset/icon_16x16@2x.png
convert "$RESIZED" -resize 32x32   AppIcon.appiconset/icon_32x32.png
convert "$RESIZED" -resize 64x64   AppIcon.appiconset/icon_32x32@2x.png
convert "$RESIZED" -resize 128x128 AppIcon.appiconset/icon_128x128.png
convert "$RESIZED" -resize 256x256 AppIcon.appiconset/icon_128x128@2x.png
convert "$RESIZED" -resize 256x256 AppIcon.appiconset/icon_256x256.png
convert "$RESIZED" -resize 512x512 AppIcon.appiconset/icon_256x256@2x.png
convert "$RESIZED" -resize 512x512 AppIcon.appiconset/icon_512x512.png
cp "$RESIZED"                      AppIcon.appiconset/icon_512x512@2x.png

# Optional: Create a Contents.json here (let me know if you want it)

# 5. Generate web-optimized 320x320
convert "$RESIZED" -resize 320x320 -strip -quality 90 "$BASENAME"-320x320-2x.png

echo "✅ Done:"
echo "• Trimmed: $TRIMMED"
echo "• 1024: $RESIZED"
echo "• Icon set: AppIcon.appiconset/"
echo "• Web image: $BASENAME-320x320-2x.png"