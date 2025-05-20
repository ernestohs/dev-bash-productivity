#!/bin/bash

# Define scripts and their descriptions
declare -A SCRIPT_DESCRIPTIONS=(
    ["auto/addAlias.sh"]="Add an alias for the last executed command"
    ["backupDir.sh"]="Backup a directory to another location"
    ["git/gitBackInTime.sh"]="Go back to a specific point in time in a Git repository"
    ["git/undoLastCommit.sh"]="Undo the last commit in a Git repository"
    ["node/deepClean.sh"]="Deep clean a Node.js project"
    ["git/upsWrongBranch.sh"]="Move last commit to a new branch (when committed to wrong branch)"
    ["git/oldBranchCleanup.sh"]="Clean up old merged branches in a Git repository"
    ["gifs/movToMp4.sh"]="Convert MOV file to MP4"
    ["gifs/toGif.sh"]="Convert MP4 file to GIF"
    ["network/whoUsesPort.sh"]="Find which process is using a specific port"
    ["network/killProcessUsingPort.sh"]="Kill the process using a specific port"
    ["bulk/rmWord.sh"]="Remove a specific word from filenames in current directory"
    ["zombie/killZombies.sh"]="Kill zombie processes"
    ["zombie/findZombies.sh"]="Find zombie processes"
    ["git/genCommitMessage.sh"]="Generate a commit message from staged changes using AI"
    ["python/boilerplate.sh"]="Create a Python project boilerplate"
)

# Function to select a script using GUM
select_script() {
    # Display the prompt message (separately from the return value)
    gum style --foreground 212 "Select a script to run:" >&2
    
    # Create a temp file for script descriptions
    local temp_file=$(mktemp)
    
    # Write script names and descriptions to temp file
    for script in "${!SCRIPT_DESCRIPTIONS[@]}"; do
        echo "$script | ${SCRIPT_DESCRIPTIONS[$script]}" >> "$temp_file"
    done
    
    # Use gum filter to select a script
    local selection=$(cat "$temp_file" | sort | gum filter --placeholder "Type to filter scripts...")
    
    # Clean up temp file
    rm "$temp_file"
    
    # Extract script name from selection
    echo "$selection" | cut -d '|' -f1 | xargs
}

# Function to handle parameters for each script
handle_script() {
    local script="$1"
    
    # Print script description
    echo "Running: ${SCRIPT_DESCRIPTIONS[$script]}" | gum style --foreground 39 --bold
    
    case "$script" in
        "auto/addAlias.sh")
            local alias_name=$(gum input --placeholder "Enter alias name")
            bash "$script" "$alias_name"
            ;;
        "backupDir.sh")
            echo "Select source directory:" | gum style --foreground 212
            local source_dir=$(gum file --directory --file=false)
            echo "Select backup directory:" | gum style --foreground 212
            local backup_dir=$(gum file --directory --file=false)
            gum spin --spinner dot --title "Backing up directory..." -- bash "$script" "$source_dir" "$backup_dir"
            ;;
        "git/gitBackInTime.sh")
            # Check if we're in a git repository
            if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
                echo "Error: Not in a git repository." | gum style --foreground 196
                exit 1
            fi
            
            local date=$(gum input --placeholder "Enter date (YYYY-MM-DD)")
            local time=$(gum input --placeholder "Enter time (HH:MM)" --value "00:00")
            echo "Select a branch:" | gum style --foreground 212
            local branches=$(git branch --format='%(refname:short)' 2>/dev/null)
            local branch=$(echo "$branches" | gum choose)
            bash "$script" -d "$date" -t "$time" -b "$branch"
            ;;
        "git/undoLastCommit.sh")
            # Check if we're in a git repository
            if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
                echo "Error: Not in a git repository." | gum style --foreground 196
                exit 1
            fi
            
            if gum confirm "This will undo the last commit. Are you sure?"; then
                bash "$script"
            else
                echo "Operation cancelled." | gum style --foreground 213
            fi
            ;;
        "node/deepClean.sh")
            if ! [ -f "package.json" ]; then
                echo "Error: Not in a Node.js project (package.json not found)." | gum style --foreground 196
                exit 1
            fi
            
            if gum confirm "This will remove node_modules and perform a clean install. Are you sure?"; then
                gum spin --spinner dot --title "Cleaning Node.js project..." -- bash "$script"
            else
                echo "Operation cancelled." | gum style --foreground 213
            fi
            ;;
        "git/upsWrongBranch.sh")
            # Check if we're in a git repository
            if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
                echo "Error: Not in a git repository." | gum style --foreground 196
                exit 1
            fi
            
            # Check if we're on the master branch
            current_branch=$(git rev-parse --abbrev-ref HEAD)
            if [ "$current_branch" != "master" ]; then
                echo "Error: You're not on the master branch. Current branch: $current_branch" | gum style --foreground 196
                exit 1
            fi
            
            local new_branch=$(gum input --placeholder "Enter the name for the new branch")
            if gum confirm "This will create a new branch '$new_branch' with the last commit, then reset the master branch. Are you sure?"; then
                echo "$new_branch" | bash "$script"
            else
                echo "Operation cancelled." | gum style --foreground 213
            fi
            ;;
        "git/oldBranchCleanup.sh")
            # Check if we're in a git repository
            if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
                echo "Error: Not in a git repository." | gum style --foreground 196
                exit 1
            fi
            
            local dry_run=""
            if gum confirm "Run in dry mode (preview without deleting)?"; then
                dry_run="-d"
            fi
            
            local protect=""
            if gum confirm "Specify protected branches?"; then
                local protected_branches=$(gum input --placeholder "Enter protected branches (comma-separated)" --value "main,master,develop")
                protect="-p $protected_branches"
            fi
            
            bash "$script" $dry_run $protect
            ;;
        "gifs/movToMp4.sh")
            echo "Select input MOV file:" | gum style --foreground 212
            local input_file=$(gum file --file-only)
            local output_file=$(gum input --placeholder "Enter output MP4 filename")
            gum spin --spinner dot --title "Converting MOV to MP4..." -- bash "$script" "$input_file" "$output_file"
            ;;
        "gifs/toGif.sh")
            echo "Select input MP4 file:" | gum style --foreground 212
            local input_file=$(gum file --file-only)
            local output_file=$(gum input --placeholder "Enter output GIF filename")
            gum spin --spinner dot --title "Converting MP4 to GIF..." -- bash "$script" "$input_file" "$output_file"
            ;;
        "network/whoUsesPort.sh"|"network/killProcessUsingPort.sh")
            local port=$(gum input --placeholder "Enter port number")
            bash "$script" "$port"
            ;;
        "bulk/rmWord.sh")
            local word=$(gum input --placeholder "Enter word to remove from filenames")
            if gum confirm "This will rename files in the current directory. Are you sure?"; then
                bash "$script" "$word"
            else
                echo "Operation cancelled." | gum style --foreground 213
            fi
            ;;
        "zombie/killZombies.sh")
            if gum confirm "This will attempt to kill zombie processes. Are you sure?"; then
                bash "$script"
            else
                echo "Operation cancelled." | gum style --foreground 213
            fi
            ;;
        "zombie/findZombies.sh")
            bash "$script"
            ;;
        "git/genCommitMessage.sh")
            # Check if we're in a git repository
            if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
                echo "Error: Not in a git repository." | gum style --foreground 196
                exit 1
            fi
            
            # Check if ollama is installed
            if ! command -v ollama &> /dev/null; then
                echo "Error: ollama is not installed. It's required for this script." | gum style --foreground 196
                exit 1
            fi
            
            gum spin --spinner dot --title "Generating commit message..." -- bash "$script"
            ;;
        "python/boilerplate.sh")
            local project_name=$(gum input --placeholder "Enter the project name")
            echo "$project_name" | bash "$script"
            ;;
        *)
            echo "Script not found: $script" | gum style --foreground 196
            exit 1
            ;;
    esac
}

# Main function
main() {
    # Check if GUM is installed
    if ! command -v gum &> /dev/null; then
        echo "Error: 'gum' is not installed. Please install it first."
        echo "See: https://github.com/charmbracelet/gum"
        exit 1
    fi
    
    # Get script name from argument or select using GUM
    local script="$1"
    if [ -z "$script" ]; then
        script=$(select_script)
    fi
    
    # Handle script parameters
    handle_script "$script"
}

main "$@"

