#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 input.mov output.mp4"
  exit 1
fi

# Assign input and output file names
INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Check if the input file is an Apple QuickTime MOV file
FILE_TYPE=$(file -b --mime-type "$INPUT_FILE")

if [ "$FILE_TYPE" != "video/quicktime" ]; then
  echo "Error: The input file is not a valid Apple MOV file."
  exit 1
fi

# Convert the MOV file to MP4 using ffmpeg
ffmpeg -i "$INPUT_FILE" -vcodec h264 -acodec aac "$OUTPUT_FILE"
