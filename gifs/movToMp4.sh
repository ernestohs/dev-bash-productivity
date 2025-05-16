#!/bin/bash

# Check for required tools
if ! command -v ffprobe &> /dev/null; then
  gum style --foreground red "❌ Error: ffprobe not found! Please install ffmpeg first."
  exit 1
fi

# Stylish header
gum style --border thick --margin "1" --padding "1 2" --border-foreground 57 \
  "🎥 $(gum style --foreground 212 'MOV to MP4 Converter') 🍿"

# Interactive file selection
INPUT_FILE=$(gum file --file --prompt "📤 Select MOV file to convert:" --height 10)
[ -f "$INPUT_FILE" ] || { gum style --foreground red "❌ File not found!"; exit 1; }

# Verify file type
FILE_TYPE=$(file -b --mime-type "$INPUT_FILE")
[[ "$FILE_TYPE" == "video/quicktime" ]] || { 
  gum style --foreground red "❌ $(gum style --bold "Invalid file type:") $(file -b "$INPUT_FILE" | cut -d ',' -f 1)"
  exit 1
}

# Generate output filename
DEFAULT_OUTPUT="${INPUT_FILE%.*}.mp4"
OUTPUT_FILE=$(gum input --value "$DEFAULT_OUTPUT" --prompt "📥 Output filename:")

# Get video duration for progress calculation
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")
DURATION=${DURATION%.*}

# Confirmation dialog
gum confirm "🚀 Start conversion from $(gum style --bold --foreground 212 "$INPUT_FILE") to $(gum style --bold --foreground 57 "$OUTPUT_FILE")?" || exit 0

# Conversion function with progress bar
convert_with_progress() {
  ffmpeg -hide_banner -i "$INPUT_FILE" -vcodec h264 -acodec aac "$OUTPUT_FILE" -y 2>&1 | \
  while IFS= read -r line; do
    if [[ "$line" =~ time=([0-9:.]+) ]]; then
      CURRENT_TIME=$(date -u -d "${BASH_REMATCH[1]}" +%s 2>/dev/null)
      PERCENT=$(( (CURRENT_TIME * 100) / DURATION ))
      
      # Build the progress bar
      BAR_LENGTH=30
      FILLED=$(( PERCENT * BAR_LENGTH / 100 ))
      EMPTY=$(( BAR_LENGTH - FILLED ))
      PROGRESS_BAR="$(printf '%*s' "$FILLED" | tr ' ' '█')"
      REMAINING_BAR="$(printf '%*s' "$EMPTY" | tr ' ' '░')"
      
      # Format with colors and emojis
      echo -ne "\r$(gum style --foreground 57 "🕒 Converting: ")\
$(gum style --foreground 212 "[${PROGRESS_BAR}${REMAINING_BAR}]")\
$(gum style --foreground 121 " ${PERCENT}% ")🎬"
    fi
  done
}

# Run conversion with spinner in parallel
(gum spin --spinner moon --title "Initializing..." -- convert_with_progress) &
SPIN_PID=$!

# Wait for completion and catch exit status
wait $SPIN_PID
STATUS=$?

# Final output
if [ $STATUS -eq 0 ]; then
  echo -e "\n\n$(gum style --border thick --foreground 46 --bold --padding "1 4" \
    "✅ $(gum style --underline 'Conversion Complete!')")\n"
  
  gum style --border rounded --margin 1 --padding "1 4" --border-foreground 99 \
    "$(gum style --foreground 212 "Input:")  $(du -h "$INPUT_FILE" | cut -f1) $(gum style --italic --faint "$INPUT_FILE")\n"\
    "$(gum style --foreground 57 "Output:") $(du -h "$OUTPUT_FILE" | cut -f1) $(gum style --italic --faint "$OUTPUT_FILE")"
else
  gum style --foreground red --bold --padding "1 4" --border thick --border-foreground red \
    "❌ $(gum style --underline 'Conversion Failed!') Check file permissions/format."
fi
