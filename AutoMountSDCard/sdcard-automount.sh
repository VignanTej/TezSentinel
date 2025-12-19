#!/bin/bash
# SD Card Auto-mount Script v3.3
# This script automatically mounts SD card partitions when inserted
# If already mounted, it unmounts and remounts fresh
# Excludes system eMMC (mmcblk2) - only mounts external SD cards
# Only mounts common data filesystems (ext2/3/4, ntfs, vfat/fat/exfat, xfs, btrfs)

ACTION=$1
DEVNAME=$2

MOUNT_BASE="/media/sdcard"
LOG_FILE="/var/log/sdcard-automount.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Create mount point if it doesn't exist
if [ ! -d "$MOUNT_BASE" ]; then
    mkdir -p "$MOUNT_BASE"
fi

case "$ACTION" in
    add)
        # Skip system eMMC (mmcblk2) - only mount external SD cards
        if [[ "$DEVNAME" =~ mmcblk2 ]]; then
            log_message "Skipping $DEVNAME - system eMMC (not external SD card)"
            exit 0
        fi
        
        # Wait a moment for the device to be ready
        sleep 1
        
        # Check if device exists and is a block device
        if [ -b "$DEVNAME" ]; then
            # Check if partition has a filesystem
            FS_TYPE=$(blkid -s TYPE -o value "$DEVNAME" 2>/dev/null)
            
            if [ -z "$FS_TYPE" ]; then
                log_message "Skipping $DEVNAME - no filesystem detected"
                exit 0
            fi
            
            # Only mount common data filesystems (exclude system/boot filesystems)
            case "$FS_TYPE" in
                ext2|ext3|ext4|ntfs|vfat|fat|exfat|xfs|btrfs)
                    # These are data filesystems, proceed with mounting
                    ;;
                *)
                    log_message "Skipping $DEVNAME - filesystem type '$FS_TYPE' not supported for auto-mount"
                    exit 0
                    ;;
            esac
            
            # Get partition name (e.g., mmcblk0p9)
            PARTITION=$(basename "$DEVNAME")
            MOUNT_POINT="$MOUNT_BASE/$PARTITION"
            
            # Check if already mounted
            if grep -qs "$DEVNAME" /proc/mounts; then
                EXISTING_MOUNT=$(grep "$DEVNAME" /proc/mounts | awk '{print $2}')
                log_message "$DEVNAME already mounted at $EXISTING_MOUNT - unmounting and remounting"
                
                # Unmount first
                if umount "$EXISTING_MOUNT" 2>> "$LOG_FILE"; then
                    log_message "Successfully unmounted $EXISTING_MOUNT"
                    # Clean up old mount point if it's not our standard location
                    if [ "$EXISTING_MOUNT" != "$MOUNT_POINT" ]; then
                        rmdir "$EXISTING_MOUNT" 2>/dev/null
                    fi
                else
                    log_message "Failed to unmount $EXISTING_MOUNT - aborting"
                    exit 1
                fi
            fi
            
            # Create mount point
            mkdir -p "$MOUNT_POINT"
            
            # Mount the partition
            if mount "$DEVNAME" "$MOUNT_POINT" 2>> "$LOG_FILE"; then
                log_message "Successfully mounted $DEVNAME ($FS_TYPE) to $MOUNT_POINT"
                # Make it accessible to regular users
                chmod 755 "$MOUNT_POINT"
            else
                log_message "Failed to mount $DEVNAME"
                rmdir "$MOUNT_POINT" 2>/dev/null
            fi
        fi
        ;;
    
    remove)
        # Get partition name
        PARTITION=$(basename "$DEVNAME")
        MOUNT_POINT="$MOUNT_BASE/$PARTITION"
        
        # Unmount if mounted
        if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
            if umount "$MOUNT_POINT" 2>> "$LOG_FILE"; then
                log_message "Successfully unmounted $MOUNT_POINT"
                rmdir "$MOUNT_POINT" 2>/dev/null
            else
                log_message "Failed to unmount $MOUNT_POINT"
            fi
        fi
        ;;
esac
