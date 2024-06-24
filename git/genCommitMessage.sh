#!/bin/bash

TEMP_DIFF_FILE="/tmp/$(uuidgen).tmp.diff"
git diff --cached > $TEMP_DIFF_FILE

PROMPT="Review the following \`git diff --cached\` output and write a concise commit message summarizing the changes:"
COMMIT_MSG=$(cat $TEMP_DIFF_FILE | ollama run -m ollama3 -p $PROMPT)

rm $TEMP_DIFF_FILE
temp_file=$(mktemp)
echo "$COMMIT_MSG" > "$temp_file"

git commit -F "$temp_file"
