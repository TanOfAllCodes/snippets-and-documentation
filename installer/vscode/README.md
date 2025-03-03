# VS Code Automatic Installer / Updater / Downgrader

<img src="https://img.shields.io/badge/OS-Ubuntu22-Green" alt="Supported OS Ubuntu 22"> 
<img src="https://img.shields.io/badge/OS-Ubuntu24-Green" alt="Supported OS Ubuntu 24">

---

This is a Bash script designed to automate the installation, updating, and downgrading of Visual Studio Code (VS Code) on Ubuntu-based systems. It leverages the GitHub API to check versions and provides a user-friendly interface for managing your VS Code installation.

## Features

- **Version Checking**: Compares your installed VS Code version with the latest release from GitHub.
- **Flexible Updates**: Choose to update to the latest version, reinstall the current version, or downgrade to a specific version.
- **Smart Downloading**: Checks if the required `.deb` file is already present before downloading, saving time and bandwidth.
- **Process Management**: Automatically detects and terminates running VS Code instances (gracefully or forcefully if needed) to ensure a smooth installation.
- **Interactive Prompts**: Offers clear choices for updating, downgrading, and cleanup with version information displayed.
- **Dependency Handling**: Fixes missing dependencies during installation if required.
- **Cleanup Control**: Asks before removing downloaded `.deb` files, allowing you to keep them if desired.
- **Verbose Output**: Provides detailed feedback at every step for transparency and troubleshooting.

## Supported Systems

- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS
- Other Debian-based systems (with `.deb` package support)

**Note**: This script is tailored for `.deb` packages (Debian/Ubuntu). Adjustments are needed for RPM-based or other systems.

## Prerequisites

- `bash`, `curl`, `wget`, `grep`, `sed`, `awk` (typically pre-installed on Ubuntu)
- `dpkg` and `apt-get` (for installation)
- `sudo` privileges
- Internet connection

## Installation and Usage

1. **Download the Script**:
   ```bash
   wget -O vscode-auto-updater.sh https://raw.githubusercontent.com/TanOfAllCodes/snippets-and-documentation/refs/heads/main/installer/vscode/vscode-auto-updater.sh
    ```
2. **Make it Executable**:
   ```bash
   chmod +x vscode-auto-updater.sh
    ```
3. **Run the Script**:
   ```bash
   ./vscode-auto-updater.sh
    ```
   - The script will guide you through the process with interactive prompts.

## How It Works

1. **Version Detection**:
   - Checks your installed VS Code version (or assumes `0.0.0` if not installed).
   - Queries the GitHub API (`microsoft/vscode`) for the latest release.

2. **User Choice**:
   - If versions match: Offers to reinstall or downgrade.
   - If a newer version exists: Offers to update, downgrade, or skip.
   - Options:
     - `y`: Install/reinstall the latest version.
     - `n`: Exit without changes.
     - `d`: Specify a custom version (e.g., `1.86.0`), validated against GitHub releases.

3. **Download and Install**:
   - Downloads the `.deb` file to the script’s directory if not already present.
   - Closes any running VS Code instances.
   - Installs the `.deb` file with `dpkg`, fixing dependencies if needed.

4. **Cleanup**:
   - Prompts to delete the downloaded `.deb` file or keep it.

## Example Output

```bash
Starting VS Code version check and update script...
--------------------------------------
Script running from: /home/user
Script PID: 12345
Checking currently installed VS Code version...
Found installed version: 1.86.0
Fetching latest version from GitHub API (microsoft/vscode)...
Latest version found on GitHub: 1.87.0
Comparing versions...
Current: 1.86.0
Latest:  1.87.0
Newer version available! You can update, downgrade, or reinstall.
Current version: 1.86.0
Latest version:  1.87.0
Would you like to update/reinstall VS Code? (y/n/d for different version)
d
Enter the version number you want to download (e.g., 1.86.0):
1.85.0
Validating version 1.85.0...
Version 1.85.0 found!
Proceeding with update/downgrade to version 1.85.0...
Downloading VS Code 1.85.0 to /home/user/vscode_1.85.0.deb...
Download completed successfully
[...]
Script completed! VS Code updated to version 1.85.0
```

## Limitations

- **Download Source**: Uses `code.visualstudio.com` for `.deb` files, which always provides the latest version. Downgrading to a specific version requires manual `.deb` file sourcing (see below).
- **OS Specificity**: Designed for Ubuntu/Debian (`.deb`). Other systems need URL and installer adjustments.
- **GitHub API**: Subject to rate limits (60 requests/hour unauthenticated). Heavy use may require a token.

## Downgrading Note

The script validates requested versions against GitHub releases, but the download URL (`code.visualstudio.com/sha/download`) only provides the latest stable `.deb`. For true downgrading:
- Maintain a local cache of `.deb` files.
- Source older versions manually and place them in the script directory.
- Future enhancement could integrate a third-party archive if available.

## Contributing

Feel free to fork this repository, submit issues, or pull requests to improve functionality (e.g., support for other OSes, better downgrade handling).

## License

This script is provided under the [MIT License](https://opensource.org/licenses/MIT). Use it freely!

---

Happy coding with VS Code!
