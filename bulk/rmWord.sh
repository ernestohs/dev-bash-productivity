#!/bin/bash

# Check if a word to remove is provided
if [ -z "$1" ]; then
  echo "Error: Please provide a word to remove as the first argument."
  exit 1
fi

# Define the word to remove
word_to_remove="$1"

# Loop through all files in the current directory
for file in *; do
  # Check if the filename contains the word to remove
  if [[ "$file" =~ .*"$word_to_remove".* ]]; then
    # Remove the word from the filename using parameter expansion
    new_filename="${file//_$word_to_remove/}"
    # Check if there's a leading or trailing underscore after removal (avoid empty filenames)
    new_filename="${new_filename%%_}"  # Remove trailing underscore
    new_filename="${new_filename##_}"  # Remove leading underscore
    
    # Rename the file only if there's a valid new filename
    if [ -n "$new_filename" ]; then
      mv "$file" "$new_filename"
      echo "Renamed: $file -> $new_filename"
    fi
  fi
done

echo "Finished processing files."

