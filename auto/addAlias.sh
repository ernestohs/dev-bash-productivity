#!/bin/bash

# Global Variables
ALIAS_FILE="${ALIAS_FILE:-$HOME/.zshrc}"
LAST_CMD=$(history | tail -n 2 | head -n 1 | sed 's/^[ 0-9]*//')
ALIAS_NAME="$1"

# Function to prompt for alias name if not provided
prompt_for_alias_name() {
    if [[ -z "$ALIAS_NAME" ]]; then
        printf "Enter the alias name: "
        read -r ALIAS_NAME
    fi
}

# Function to validate the last command
validate_last_command() {
    if [[ -z "$LAST_CMD" ]]; then
        printf "Error: Unable to retrieve the last command.\n" >&2
        return 1
    fi
}

# Function to add alias to the alias file
add_alias() {
    if ! printf "alias %s='%s'\n" "$ALIAS_NAME" "$LAST_CMD" >> "$ALIAS_FILE"; then
        printf "Error: Failed to add alias to %s\n" "$ALIAS_FILE" >&2
        return 1
    fi
    printf "Alias '%s' added successfully to %s\n" "$ALIAS_NAME" "$ALIAS_FILE"
}

# Main function
main() {
    prompt_for_alias_name
    validate_last_command || return 1
    add_alias || return 1
}

main "$@"
