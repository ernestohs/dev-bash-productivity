#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 input.mp4 output.gif"
  exit 1
fi

# Assign input and output file names
INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Set the frame rate (you can adjust this as needed)
FRAME_RATE=10

# Create a palette for better color accuracy
PALETTE="/tmp/palette.png"

# Generate the palette
ffmpeg -y -i "$INPUT_FILE" -vf "fps=$FRAME_RATE,scale=320:-1:flags=lanczos,palettegen" "$PALETTE"

# Generate the GIF using the palette
ffmpeg -i "$INPUT_FILE" -i "$PALETTE" -lavfi "fps=$FRAME_RATE,scale=320:-1:flags=lanczos [x]; [x][1:v] paletteuse" "$OUTPUT_FILE"

# Clean up
rm "$PALETTE"

echo "GIF created successfully: $OUTPUT_FILE"
