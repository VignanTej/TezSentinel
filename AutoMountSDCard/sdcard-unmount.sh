#!/bin/bash
# SD Card Auto-unmount Script
# Called by udev when SD card partition is removed

PARTITION=$1
MOUNT_POINT="/media/sdcard/$PARTITION"
LOG_FILE="/var/log/sdcard-automount.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if mount point exists and is mounted
if [ -d "$MOUNT_POINT" ]; then
    if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
        if umount "$MOUNT_POINT" 2>> "$LOG_FILE"; then
            log_message "Successfully unmounted $MOUNT_POINT"
            rmdir "$MOUNT_POINT" 2>/dev/null
        else
            log_message "Failed to unmount $MOUNT_POINT"
        fi
    else
        # Not mounted, just remove the directory
        rmdir "$MOUNT_POINT" 2>/dev/null
    fi
fi
