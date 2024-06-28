#!/bin/bash

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not in a git repository."
    exit 1
fi

# Check if we're on the master branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "master" ]; then
    echo "Error: You're not on the master branch. Current branch: $current_branch"
    exit 1
fi

# Ask the user for the new branch name
read -p "Enter the name for the new branch: " new_branch_name

# Confirm with the user
echo "This will create a new branch '$new_branch_name' with the last commit,"
echo "then reset the master branch to the previous commit."
read -p "Are you sure you want to proceed? (y/n): " confirm

if [[ $confirm != [yY] ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Execute the git commands
git branch "$new_branch_name"
git reset HEAD~ --hard
git checkout "$new_branch_name"

echo "Operation completed successfully."
echo "New branch '$new_branch_name' created with the last commit."
echo "Master branch has been reset to the previous commit."
echo "You are now on branch '$new_branch_name'."
