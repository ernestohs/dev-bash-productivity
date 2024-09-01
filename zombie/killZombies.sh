#!/bin/bash

# Function to identify and kill zombie processes
kill_zombie_processes() {
    # Get a list of all zombie processes' PIDs and their parent process IDs (PPIDs)
    local zombies; zombies=$(ps aux | awk '$8 == "Z" {print $2 ":" $3}')

    if [[ -z "$zombies" ]]; then
        printf "No zombie processes found.\n"
        return 0
    fi

    # Loop through the list of zombies
    local pid ppid
    while IFS=: read -r pid ppid; do
        printf "Zombie process found: PID=%s, PPID=%s\n" "$pid" "$ppid"
        
        # Attempt to kill the parent process to remove the zombie
        if kill -HUP "$ppid" 2>/dev/null; then
            printf "Sent SIGHUP to parent process (PID=%s) of zombie (PID=%s).\n" "$ppid" "$pid"
        else
            printf "Failed to send SIGHUP to parent process (PID=%s).\n" "$ppid" >&2
            return 1
        fi
    done <<< "$zombies"
}

# Main function
main() {
    kill_zombie_processes
}

main "$@"
