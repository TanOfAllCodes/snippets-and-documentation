#!/bin/bash

# Script to check, download, install, and cleanup VS Code updates with verbose output

echo "Starting VS Code version check and update script..."
echo "--------------------------------------"

# Get the script's directory and PID
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PID=$$
echo "Script running from: $SCRIPT_DIR"
echo "Script PID: $SCRIPT_PID"

# Get the currently installed version
echo "Checking currently installed VS Code version..."
if command -v code >/dev/null 2>&1; then
    CURRENT_VERSION=$(code --version | head -n 1)
    echo "Found installed version: $CURRENT_VERSION"
else
    echo "VS Code not found in system PATH!"
    echo "Assuming no installation present; will proceed with download"
    CURRENT_VERSION="0.0.0"  # Dummy version for comparison
fi

# Fetch the latest version from GitHub releases
echo "Fetching latest version from GitHub API (microsoft/vscode)..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/microsoft/vscode/releases/latest | 
    grep '"tag_name":' | 
    sed -E 's/.*"tag_name": "([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to fetch latest version from GitHub API!"
    echo "Check your internet connection or GitHub API availability"
    exit 1
else
    echo "Latest version found on GitHub: $LATEST_VERSION"
fi

# Compare versions
echo "Comparing versions..."
echo "Current: $CURRENT_VERSION"
echo "Latest:  $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "You're running the latest version, but you can still downgrade or reinstall."
else
    echo "Newer version available! You can update, downgrade, or reinstall."
fi

# Define default download URL and file
DOWNLOAD_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
SELECTED_VERSION="$LATEST_VERSION"
DEB_FILE="$SCRIPT_DIR/vscode_$SELECTED_VERSION.deb"

# Prompt for update with option to choose different version
while true; do
    echo "Current version: $CURRENT_VERSION"
    echo "Latest version:  $LATEST_VERSION"
    echo "Would you like to update/reinstall VS Code? (y/n/d for different version)"
    read -r ANSWER
    case $ANSWER in
        [Yy]*)
            echo "Proceeding with update/reinstall to latest version ($LATEST_VERSION)..."
            break
            ;;
        [Nn]*)
            echo "No changes made. Staying on version $CURRENT_VERSION"
            exit 0
            ;;
        [Dd]*)
            echo "Enter the version number you want to download (e.g., 1.86.0):"
            read -r CUSTOM_VERSION
            echo "Validating version $CUSTOM_VERSION..."
            # Check if the version exists in GitHub releases
            VERSION_CHECK=$(curl -s "https://api.github.com/repos/microsoft/vscode/releases" | 
                grep '"tag_name": "'"$CUSTOM_VERSION"'"')
            if [ -n "$VERSION_CHECK" ]; then
                echo "Version $CUSTOM_VERSION found!"
                SELECTED_VERSION="$CUSTOM_VERSION"
                DEB_FILE="$SCRIPT_DIR/vscode_$SELECTED_VERSION.deb"
                echo "Proceeding with update/downgrade to version $SELECTED_VERSION..."
                break
            else
                echo "Error: Version $CUSTOM_VERSION not found in VS Code releases!"
                echo "Please try again or choose a valid version."
            fi
            ;;
        *)
            echo "Please answer y, n, or d"
            ;;
    esac
done

# Check if the .deb file already exists
if [ -f "$DEB_FILE" ]; then
    echo "Found existing download: $DEB_FILE"
else
    # Construct the version-specific download URL
    DOWNLOAD_URL="https://update.code.visualstudio.com/$SELECTED_VERSION/linux-deb-x64/stable"
    echo "Downloading VS Code $SELECTED_VERSION from $DOWNLOAD_URL to $DEB_FILE..."
    curl -L -o "$DEB_FILE" "$DOWNLOAD_URL"
    if [ $? -ne 0 ]; then
        echo "Download failed! The version $SELECTED_VERSION might not be available."
        echo "Please verify the version exists or check your internet connection."
        rm -f "$DEB_FILE"  # Remove any partial download
        exit 1
    else
        echo "Download completed successfully"
    fi
fi

# Check if VS Code is running and kill it if necessary
echo "Checking for running VS Code instances..."
VS_CODE_PIDS=$(ps -eo pid,cmd | grep -E '[/]code(\s|$)' | grep -v "$SCRIPT_PID" | awk '{print $1}')
if [ -n "$VS_CODE_PIDS" ]; then
    echo "Found VS Code processes with PIDs: $VS_CODE_PIDS"
    echo "Attempting to close VS Code gracefully..."
    for PID in $VS_CODE_PIDS; do
        kill -TERM "$PID" 2>/dev/null
    done
    sleep 2
    STILL_RUNNING=$(ps -eo pid,cmd | grep -E '[/]code(\s|$)' | grep -v "$SCRIPT_PID" | awk '{print $1}')
    if [ -n "$STILL_RUNNING" ]; then
        echo "Warning: Some VS Code processes didn’t terminate. Forcing kill..."
        for PID in $STILL_RUNNING; do
            kill -9 "$PID" 2>/dev/null
        done
        echo "Forced termination of PIDs: $STILL_RUNNING"
    else
        echo "VS Code closed successfully"
    fi
else
    echo "No running VS Code instances found"
fi

# Install the .deb file
echo "Installing VS Code $LATEST_VERSION..."
if sudo dpkg -i "$DEB_FILE"; then
    echo "Installation completed successfully"
else
    echo "Installation failed! Attempting to fix dependencies..."
    sudo apt-get install -f -y
    if [ $? -eq 0 ]; then
        echo "Dependencies fixed and installation completed"
    else
        echo "Installation failed even after fixing dependencies!"
        exit 1
    fi
fi

# Prompt for cleanup
while true; do
    echo "Would you like to clean up the downloaded file ($DEB_FILE)? (y/n)"
    read -r CLEANUP_ANSWER
    case $CLEANUP_ANSWER in
        [Yy]*)
            echo "Cleaning up downloaded file..."
            rm -f "$DEB_FILE"
            if [ $? -eq 0 ]; then
                echo "Cleanup completed: $DEB_FILE removed"
            else
                echo "Warning: Failed to remove $DEB_FILE"
            fi
            break
            ;;
        [Nn]*)
            echo "Keeping downloaded file: $DEB_FILE"
            break
            ;;
        *)
            echo "Please answer y or n"
            ;;
    esac
done

echo "--------------------------------------"
echo "Script completed! VS Code updated to version $LATEST_VERSION"
