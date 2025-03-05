#!/bin/bash
# Installation script for macOS Memory Optimiser

echo "Installing macOS Memory Optimiser..."

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This tool is designed for macOS only."
    exit 1
fi

# Get the source directory (where the script is located)
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create directory structure
INSTALL_DIR="$HOME/memory-optimiser"
echo "Creating installation directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR/logs"

# Copy files
echo "Copying files from $SOURCE_DIR..."
cp "$SOURCE_DIR/memory_optimiser.py" "$INSTALL_DIR/"
cp "$SOURCE_DIR/start_memory_optimiser.sh" "$INSTALL_DIR/"
cp "$SOURCE_DIR/README.md" "$INSTALL_DIR/"

# Make scripts executable
echo "Setting permissions..."
chmod +x "$INSTALL_DIR/memory_optimiser.py"
chmod +x "$INSTALL_DIR/start_memory_optimiser.sh"

# Install dependencies
echo "Installing dependencies..."
pip3 install psutil

# Create an alias in .zshrc or .bash_profile
SHELL_PROFILE=""
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_PROFILE="$HOME/.bash_profile"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if [[ -n "$SHELL_PROFILE" ]]; then
    echo "Adding alias to $SHELL_PROFILE..."
    echo "" >> "$SHELL_PROFILE"
    echo "# macOS Memory Optimiser" >> "$SHELL_PROFILE"
    echo "alias memory-optimiser='cd $INSTALL_DIR && ./start_memory_optimiser.sh'" >> "$SHELL_PROFILE"
    echo "Installation complete! Please restart your terminal or run 'source $SHELL_PROFILE'"
    echo "Then you can run the memory optimiser by typing 'memory-optimiser'"
else
    echo "Could not find shell profile to add alias."
    echo "Installation complete! You can run the memory optimiser by navigating to $INSTALL_DIR and running ./start_memory_optimiser.sh"
fi

# Optional: Create a LaunchAgent for automatic startup
read -p "Would you like to set up the memory optimiser to run automatically at login? (y/n) " AUTO_START
if [[ "$AUTO_START" == "y" || "$AUTO_START" == "Y" ]]; then
    PLIST_FILE="$HOME/Library/LaunchAgents/com.user.memoryoptimiser.plist"
    echo "Creating LaunchAgent at $PLIST_FILE..."

    mkdir -p "$HOME/Library/LaunchAgents"

    cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.memoryoptimiser</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>cd $INSTALL_DIR && ./start_memory_optimiser.sh --gentle --background</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardErrorPath</key>
    <string>$INSTALL_DIR/logs/launchd_error.log</string>
    <key>StandardOutPath</key>
    <string>$INSTALL_DIR/logs/launchd_output.log</string>
</dict>
</plist>
EOF

    # Load the LaunchAgent
    launchctl load "$PLIST_FILE"
    echo "LaunchAgent created and loaded. The memory optimiser will run automatically at login with gentle settings."
    echo "To disable automatic startup, run: launchctl unload $PLIST_FILE"
fi

echo ""
echo "Thank you for installing the macOS Memory Optimiser!"
echo "For more information and usage instructions, see $INSTALL_DIR/README.md"