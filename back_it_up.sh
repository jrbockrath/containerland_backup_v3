#!/bin/bash

# Set your GitHub username and desired repository name
GITHUB_USER="jrbockrath"
NEW_REPO_NAME="containerland_backup_v3"
REMOTE_URL="git@github.com:$GITHUB_USER/$NEW_REPO_NAME.git"

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

# Authenticate with GitHub CLI
gh auth status &> /dev/null || gh auth login --web

# Navigate to the containerland directory
cd /home/jamesrbockrath/container_land || { echo "Failed to access /home/jamesrbockrath/container_land"; exit 1; }

# Remove any existing .git directory
rm -rf .git

# Initialize a new Git repository
git init

# Ensure all files are included, even hidden ones
shopt -s dotglob
git add --all

# Confirm all files have been added
if [ -z "$(git status --porcelain)" ]; then
    echo "No files added. Check the directory contents and .gitignore settings."
    exit 1
fi

# Check if swsystem folder and its contents are included
if [ ! -d "swsystem" ] || [ -z "$(git ls-files swsystem)" ]; then
    echo "Error: swsystem directory is missing or not added correctly."
    exit 1
fi

# Commit the changes
git commit -m "Initial commit with containerland contents"

# Create the GitHub repository
gh repo create "$NEW_REPO_NAME" --public --source=. --remote=origin || { echo "Failed to create GitHub repository"; exit 1; }

# Set the remote URL and push changes
git remote remove origin
git remote add origin $REMOTE_URL
git branch -M main
git push -u origin main --force || { echo "Push to GitHub failed. Check SSH/HTTPS settings."; exit 1; }

echo "Backup completed! Your containerland directory is now in the $NEW_REPO_NAME repository."
