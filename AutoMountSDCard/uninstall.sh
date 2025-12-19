#!/bin/bash
# SD Card Auto-Mount System Uninstaller
# This script removes the auto-mount system

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

echo -e "${YELLOW}==========================================${NC}"
echo -e "${YELLOW}SD Card Auto-Mount System Uninstaller${NC}"
echo -e "${YELLOW}==========================================${NC}"
echo ""
echo -e "Uninstalling for user: ${YELLOW}${INSTALL_USER}${NC}"
echo -e "Home directory: ${YELLOW}${INSTALL_HOME}${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run with sudo${NC}"
    echo "Usage: sudo ./uninstall.sh"
    exit 1
fi

# Confirmation
read -p "Are you sure you want to uninstall the SD Card Auto-Mount system? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo ""

# Step 1: Stop any running services
echo -e "${YELLOW}[1/6]${NC} Stopping active services..."
systemctl stop 'sdcard-automount@*.service' 2>/dev/null || true
systemctl stop 'sdcard-unmount@*.service' 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} Services stopped"

# Step 2: Remove symlink
echo -e "${YELLOW}[2/6]${NC} Removing access symlink..."
SYMLINK_PATH="${INSTALL_HOME}/sdcard_data"
if [ -L "$SYMLINK_PATH" ]; then
    rm "$SYMLINK_PATH"
    echo -e "  ${GREEN}✓${NC} Removed symlink: $SYMLINK_PATH"
else
    echo -e "  ${YELLOW}→${NC} Symlink not found (may have been removed already)"
fi

# Step 3: Remove sudoers rule
echo -e "${YELLOW}[3/6]${NC} Removing sudoers rule..."
if [ -f /etc/sudoers.d/sdcard-automount ]; then
    rm /etc/sudoers.d/sdcard-automount
    echo -e "  ${GREEN}✓${NC} Removed /etc/sudoers.d/sdcard-automount"
else
    echo -e "  ${YELLOW}→${NC} Sudoers rule not found"
fi

# Step 4: Remove udev rule
echo -e "${YELLOW}[4/6]${NC} Removing udev rule..."
if [ -f /etc/udev/rules.d/99-sdcard-automount.rules ]; then
    rm /etc/udev/rules.d/99-sdcard-automount.rules
    udevadm control --reload-rules
    udevadm trigger
    echo -e "  ${GREEN}✓${NC} Removed udev rule and reloaded"
else
    echo -e "  ${YELLOW}→${NC} Udev rule not found"
fi

# Step 5: Remove systemd services
echo -e "${YELLOW}[5/6]${NC} Removing systemd services..."
if [ -f /etc/systemd/system/sdcard-automount@.service ]; then
    rm /etc/systemd/system/sdcard-automount@.service
    echo -e "  ${GREEN}✓${NC} Removed sdcard-automount@.service"
else
    echo -e "  ${YELLOW}→${NC} Mount service not found"
fi

if [ -f /etc/systemd/system/sdcard-unmount@.service ]; then
    rm /etc/systemd/system/sdcard-unmount@.service
    echo -e "  ${GREEN}✓${NC} Removed sdcard-unmount@.service"
else
    echo -e "  ${YELLOW}→${NC} Unmount service not found"
fi

# Remove old service if exists
if [ -f /etc/systemd/system/sdcard-automount-remove@.service ]; then
    rm /etc/systemd/system/sdcard-automount-remove@.service
    echo -e "  ${GREEN}✓${NC} Removed old sdcard-automount-remove@.service"
fi

systemctl daemon-reload
echo -e "  ${GREEN}✓${NC} Systemd reloaded"

# Step 6: Remove scripts
echo -e "${YELLOW}[6/6]${NC} Removing mount/unmount scripts..."
if [ -f /usr/local/bin/sdcard-automount.sh ]; then
    rm /usr/local/bin/sdcard-automount.sh
    echo -e "  ${GREEN}✓${NC} Removed /usr/local/bin/sdcard-automount.sh"
else
    echo -e "  ${YELLOW}→${NC} Mount script not found"
fi

if [ -f /usr/local/bin/sdcard-unmount.sh ]; then
    rm /usr/local/bin/sdcard-unmount.sh
    echo -e "  ${GREEN}✓${NC} Removed /usr/local/bin/sdcard-unmount.sh"
else
    echo -e "  ${YELLOW}→${NC} Unmount script not found"
fi

# Summary
echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}Uninstallation Complete!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo "The following have been removed:"
echo "  • Mount/unmount scripts from /usr/local/bin/"
echo "  • Systemd services from /etc/systemd/system/"
echo "  • Udev rule from /etc/udev/rules.d/"
echo "  • Sudoers rule from /etc/sudoers.d/"
echo "  • Access symlink from ${SYMLINK_PATH}"
echo ""
echo -e "${YELLOW}Note:${NC} The following were NOT removed:"
echo "  • /media/sdcard directory (may contain mount points)"
echo "  • /var/log/sdcard-automount.log (contains operation history)"
echo ""
echo "To manually remove these:"
echo "  sudo rmdir /media/sdcard  # (if empty)"
echo "  sudo rm /var/log/sdcard-automount.log"
echo ""
echo -e "${GREEN}Uninstallation completed successfully!${NC}"
