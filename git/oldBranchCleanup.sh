#!/bin/bash

# Default values
DRY_RUN=false
PROTECTED_BRANCHES="main,master,develop"
RED='\033[0;31m'
NC='\033[0m' # No Color

# Help message
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Delete merged Git branches while protecting specified branches."
    echo
    echo "Options:"
    echo "  -d, --dry-run         Show what would be deleted without actually deleting"
    echo "  -p, --protect         Comma-separated list of branches to protect"
    echo "  -h, --help            Show this help message"
    echo
    echo "Environment variables:"
    echo "  GIT_PROTECTED_BRANCHES    Comma-separated list of protected branches"
    echo "                            (overrides default but can be overridden by -p)"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -p|--protect)
            PROTECTED_BRANCHES="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Use environment variable if set
if [ ! -z "$GIT_PROTECTED_BRANCHES" ]; then
    PROTECTED_BRANCHES="$GIT_PROTECTED_BRANCHES"
fi

# Convert protected branches to array
IFS=',' read -ra PROTECTED_ARRAY <<< "$PROTECTED_BRANCHES"

# Create protected branches pattern for grep
PROTECTED_PATTERN=$(printf "|%s" "${PROTECTED_ARRAY[@]}")
PROTECTED_PATTERN=${PROTECTED_PATTERN:1}

# Function to delete or show branch
delete_branch() {
    local branch=$1
    if [ "$DRY_RUN" = true ]; then
        echo -e "${RED}[ DELETE ]${NC} $branch"
    else
        git branch -d "$branch" 2>/dev/null || {
            echo "Warning: Could not delete branch $branch"
        }
    fi
}

# Get current branch
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)

echo "Checking for merged branches..."
echo "Protected branches: ${PROTECTED_BRANCHES}"
echo "Current branch: ${CURRENT_BRANCH}"
echo

# Find and process merged branches
git branch --merged | 
    grep -v "^\*" | # Exclude current branch marker
    grep -vE "^[[:space:]]*($PROTECTED_PATTERN)[[:space:]]*$" | # Exclude protected branches
    while read -r branch; do
        # Trim whitespace
        branch=$(echo "$branch" | tr -d '[:space:]')
        # Skip if branch is current branch
        if [ "$branch" = "$CURRENT_BRANCH" ]; then
            continue
        fi
        delete_branch "$branch"
    done

if [ "$DRY_RUN" = true ]; then
    echo -e "\nDry run completed. No branches were actually deleted."
    echo "Run without -d or --dry-run to perform actual deletion."
else
    echo -e "\nBranch cleanup completed."
fi

