#!/bin/bash

# Global Variables
SOURCE_DIR="$1"
BACKUP_DIR="$2"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
LOG_FILE="/var/log/backup_script.log"

# Ensure source and backup directories are provided
validate_directories() {
    if [[ -z "$SOURCE_DIR" || -z "$BACKUP_DIR" ]]; then
        printf "Usage: %s <source_directory> <backup_directory>\n" "$0" >&2
        return 1
    fi
}

# Create the backup directory if it doesn't exist
prepare_backup_dir() {
    mkdir -p "$BACKUP_DIR" || { 
        printf "Failed to create backup directory: %s\n" "$BACKUP_DIR" >&2 
        return 1 
    }
}

# Perform the backup using rsync
perform_backup() {
    local backup_subdir; backup_subdir="$BACKUP_DIR/backup_$TIMESTAMP"
    mkdir -p "$backup_subdir" || {
        printf "Failed to create subdirectory for the backup: %s\n" "$backup_subdir" >&2
        return 1
    }
    
    if ! rsync -a --delete "$SOURCE_DIR/" "$backup_subdir/"; then
        printf "Backup failed: %s to %s\n" "$SOURCE_DIR" "$backup_subdir" >&2
        return 1
    fi
    
    printf "Backup successful: %s to %s\n" "$SOURCE_DIR" "$backup_subdir" >> "$LOG_FILE"
}

# Main function
main() {
    validate_directories || return 1
    prepare_backup_dir || return 1
    perform_backup || return 1
}

main "$@"
