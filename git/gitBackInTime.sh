#!/bin/bash

# Function to display script usage
show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]
Go back to a specific point in time in the Git repository.

Options:
    -d, --date        Date in format YYYY-MM-DD (required)
    -t, --time        Time in format HH:MM (default: 00:00)
    -b, --branch      Branch name (default: master)
    -h, --help        Display this help message

Example:
    $(basename "$0") -d 2014-06-10 -t 12:00 -b main
    $(basename "$0") --date 2014-06-10 --time 12:00 --branch master
EOF
    exit 1
}

# Function to validate date format
validate_date() {
    local date=$1
    if ! [[ $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Error: Invalid date format. Use YYYY-MM-DD"
        exit 1
    }
    
    # Validate date exists
    if ! date -d "$date" >/dev/null 2>&1; then
        echo "Error: Invalid date. Please provide a valid date"
        exit 1
    }
}

# Function to validate time format
validate_time() {
    local time=$1
    if ! [[ $time =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
        echo "Error: Invalid time format. Use HH:MM (24-hour format)"
        exit 1
    }
}

# Function to validate if current directory is a git repository
validate_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository"
        exit 1
    }
}

# Function to validate if branch exists
validate_branch() {
    local branch=$1
    if ! git show-ref --verify --quiet "refs/heads/$branch"; then
        echo "Error: Branch '$branch' does not exist"
        exit 1
    }
}

# Initialize default values
DATE=""
TIME="00:00"
BRANCH="master"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--date)
            DATE="$2"
            shift 2
            ;;
        -t|--time)
            TIME="$2"
            shift 2
            ;;
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            echo "Error: Unknown option $1"
            show_usage
            ;;
    esac
done

# Check if date is provided
if [ -z "$DATE" ]; then
    echo "Error: Date is required"
    show_usage
fi

# Validate inputs
validate_git_repo
validate_date "$DATE"
validate_time "$TIME"
validate_branch "$BRANCH"

# Combine date and time
DATETIME="$DATE $TIME"

# Save current branch name
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)

# Perform the checkout
echo "Going back to $DATETIME on branch $BRANCH..."
if ! git checkout $(git rev-list -n 1 --before="$DATETIME" "$BRANCH"); then
    echo "Error: Could not find commit before $DATETIME on branch $BRANCH"
    echo "Returning to previous branch $CURRENT_BRANCH..."
    git checkout "$CURRENT_BRANCH"
    exit 1
fi

echo "Successfully moved to the state of repository at $DATETIME"
echo "NOTE: You are now in 'detached HEAD' state"
echo "To return to the latest state, use: git checkout $BRANCH"
