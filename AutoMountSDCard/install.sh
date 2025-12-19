#!/bin/bash
# SD Card Auto-Mount System Installer
# This script installs the auto-mount system for any user

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the user who invoked sudo (or current user if not using sudo)
if [ -n "$SUDO_USER" ]; then
    INSTALL_USER="$SUDO_USER"
    INSTALL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    INSTALL_USER="$USER"
    INSTALL_HOME="$HOME"
fi

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}SD Card Auto-Mount System Installer${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo -e "Installing for user: ${YELLOW}${INSTALL_USER}${NC}"
echo -e "Home directory: ${YELLOW}${INSTALL_HOME}${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run with sudo${NC}"
    echo "Usage: sudo ./install.sh"
    exit 1
fi

# Check if all required files exist
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIRED_FILES=(
    "sdcard-automount.sh"
    "sdcard-unmount.sh"
    "sdcard-automount@.service"
    "sdcard-unmount@.service"
    "99-sdcard-automount.rules"
    "sdcard-automount-sudoers"
)

echo "Checking required files..."
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$SCRIPT_DIR/$file" ]; then
        echo -e "${RED}Error: Required file '$file' not found in $SCRIPT_DIR${NC}"
        exit 1
    fi
    echo -e "  ${GREEN}✓${NC} $file"
done
echo ""

# Step 1: Install scripts
echo -e "${YELLOW}[1/6]${NC} Installing mount/unmount scripts..."
cp "$SCRIPT_DIR/sdcard-automount.sh" /usr/local/bin/
cp "$SCRIPT_DIR/sdcard-unmount.sh" /usr/local/bin/
chmod +x /usr/local/bin/sdcard-automount.sh
chmod +x /usr/local/bin/sdcard-unmount.sh
echo -e "  ${GREEN}✓${NC} Scripts installed to /usr/local/bin/"

# Step 2: Install systemd services
echo -e "${YELLOW}[2/6]${NC} Installing systemd services..."
cp "$SCRIPT_DIR/sdcard-automount@.service" /etc/systemd/system/
cp "$SCRIPT_DIR/sdcard-unmount@.service" /etc/systemd/system/
systemctl daemon-reload
echo -e "  ${GREEN}✓${NC} Systemd services installed and reloaded"

# Step 3: Install udev rule
echo -e "${YELLOW}[3/6]${NC} Installing udev rule..."
cp "$SCRIPT_DIR/99-sdcard-automount.rules" /etc/udev/rules.d/
udevadm control --reload-rules
udevadm trigger
echo -e "  ${GREEN}✓${NC} Udev rule installed and activated"

# Step 4: Install sudoers rule
echo -e "${YELLOW}[4/6]${NC} Installing sudoers rule..."
cp "$SCRIPT_DIR/sdcard-automount-sudoers" /etc/sudoers.d/sdcard-automount
chmod 0440 /etc/sudoers.d/sdcard-automount

# Verify sudoers syntax
if visudo -c -f /etc/sudoers.d/sdcard-automount > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Sudoers rule installed and verified"
else
    echo -e "  ${RED}✗${NC} Sudoers syntax error - removing file"
    rm /etc/sudoers.d/sdcard-automount
    exit 1
fi

# Step 5: Create mount base directory
echo -e "${YELLOW}[5/6]${NC} Creating mount directories..."
mkdir -p /media/sdcard
echo -e "  ${GREEN}✓${NC} Created /media/sdcard"

# Step 6: Create symlink for user
echo -e "${YELLOW}[6/6]${NC} Creating access symlink..."
SYMLINK_PATH="${INSTALL_HOME}/sdcard_data"

# Remove existing symlink or directory if it exists
if [ -L "$SYMLINK_PATH" ]; then
    rm "$SYMLINK_PATH"
    echo -e "  ${YELLOW}→${NC} Removed existing symlink"
elif [ -d "$SYMLINK_PATH" ]; then
    echo -e "  ${YELLOW}!${NC} Directory $SYMLINK_PATH already exists"
    echo -e "     Please remove it manually if you want to create a symlink"
else
    ln -s /media/sdcard "$SYMLINK_PATH"
    chown -h "$INSTALL_USER:$INSTALL_USER" "$SYMLINK_PATH"
    echo -e "  ${GREEN}✓${NC} Created symlink: $SYMLINK_PATH -> /media/sdcard"
fi

# Summary
echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo "System Components Installed:"
echo "  • Mount script: /usr/local/bin/sdcard-automount.sh"
echo "  • Unmount script: /usr/local/bin/sdcard-unmount.sh"
echo "  • Systemd services: /etc/systemd/system/sdcard-*.service"
echo "  • Udev rule: /etc/udev/rules.d/99-sdcard-automount.rules"
echo "  • Sudoers rule: /etc/sudoers.d/sdcard-automount"
echo "  • Access point: ${SYMLINK_PATH}"
echo ""
echo "Usage:"
echo "  • Insert SD card → Auto-mounts to ${SYMLINK_PATH}/"
echo "  • Remove SD card → Auto-unmounts"
echo "  • View logs: tail -f /var/log/sdcard-automount.log"
echo ""
echo -e "${YELLOW}Test the installation:${NC}"
echo "  1. Insert an SD card"
echo "  2. Check: ls ${SYMLINK_PATH}/"
echo "  3. Remove the SD card"
echo "  4. Check logs: tail /var/log/sdcard-automount.log"
echo ""
echo -e "${GREEN}Installation completed successfully!${NC}"
