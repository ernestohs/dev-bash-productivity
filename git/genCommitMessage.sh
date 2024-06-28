#!/bin/bash -x

TEMP_DIFF_FILE="/tmp/$(uuidgen).tmp.diff"
git diff --cached > $TEMP_DIFF_FILE

PROMPT="Review the following \`git diff --cached\` output and write a concise commit message summarizing the changes:"
COMMIT_MSG=$(ollama run llama3 "$PROMPT $(cat $TEMP_DIFF_FILE)" )
echo "$COMMIT_MSG"
rm $TEMP_DIFF_FILE
echo "$COMMIT_MSG"
