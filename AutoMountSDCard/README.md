# SD Card Auto-Mount System

Automatic SD card mounting and unmounting system for Linux using udev and systemd.

## Overview

This system automatically mounts SD card partitions when inserted and unmounts them when removed. It intelligently handles cases where partitions are already mounted by unmounting and remounting them fresh.

## Features

- ✅ **Automatic mounting** on SD card insertion
- ✅ **Automatic unmounting** on SD card removal
- ✅ **Intelligent remount** - unmounts and remounts if already mounted
- ✅ **Filesystem detection** - only mounts partitions with valid filesystems
- ✅ **Works with any SD card** - not device-specific
- ✅ **User-agnostic** - automatically detects and configures for any user
- ✅ **Comprehensive logging** - all operations logged to `/var/log/sdcard-automount.log`
- ✅ **Convenient access** - symlink at `~/sdcard_data` for easy access

## System Components

### 1. Mount Script
- **File:** `sdcard-automount.sh`
- **Location:** `/usr/local/bin/sdcard-automount.sh`
- **Purpose:** Handles mounting logic, filesystem detection, and remounting

### 2. Unmount Script
- **File:** `sdcard-unmount.sh`
- **Location:** `/usr/local/bin/sdcard-unmount.sh`
- **Purpose:** Handles unmounting and cleanup of mount points

### 3. Systemd Services
- **Mount Service:** `sdcard-automount@.service` → `/etc/systemd/system/`
- **Unmount Service:** `sdcard-unmount@.service` → `/etc/systemd/system/`
- **Purpose:** Template services triggered by udev for each partition

### 4. Udev Rule
- **File:** `99-sdcard-automount.rules`
- **Location:** `/etc/udev/rules.d/99-sdcard-automount.rules`
- **Purpose:** Detects SD card insertion/removal and triggers systemd services

### 5. Sudoers Rule
- **File:** `sdcard-automount-sudoers`
- **Location:** `/etc/sudoers.d/sdcard-automount`
- **Purpose:** Allows unmount script to run with root privileges

## Quick Installation

### Automatic Installation (Recommended)

1. Navigate to the AutoMountSDCard directory:
```bash
cd ~/TezSentinel/AutoMountSDCard
```

2. Run the installer:
```bash
sudo ./install.sh
```

The installer will:
- ✅ Install mount and unmount scripts
- ✅ Configure systemd services
- ✅ Set up udev rules for hotplug detection
- ✅ Configure sudo permissions
- ✅ Create convenient access symlink at `~/sdcard_data`
- ✅ Work for any user (automatically detects the user running it)

### Manual Installation

If you prefer manual installation, follow these steps:

#### Step 1: Copy Scripts
```bash
sudo cp sdcard-automount.sh /usr/local/bin/
sudo cp sdcard-unmount.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/sdcard-automount.sh
sudo chmod +x /usr/local/bin/sdcard-unmount.sh
```

#### Step 2: Install Systemd Services
```bash
sudo cp sdcard-automount@.service /etc/systemd/system/
sudo cp sdcard-unmount@.service /etc/systemd/system/
sudo systemctl daemon-reload
```

#### Step 3: Install Udev Rule
```bash
sudo cp 99-sdcard-automount.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
```

#### Step 4: Install Sudoers Rule
```bash
sudo cp sdcard-automount-sudoers /etc/sudoers.d/sdcard-automount
sudo chmod 0440 /etc/sudoers.d/sdcard-automount
sudo visudo -c  # Verify syntax
```

#### Step 5: Create Access Symlink
```bash
sudo mkdir -p /media/sdcard
ln -s /media/sdcard ~/sdcard_data
```

## Usage

### Access Mounted SD Card
All mounted partitions appear at:
```bash
/home/pi/sdcard_data/
```

Example:
```bash
ls /home/pi/sdcard_data/
# Shows: mmcblk0p8  mm
cblk0p9

ls /home/pi/sdcard_data/mmcblk0p9/
# Shows your data directories
```

### View Logs
```bash
tail -f /var/log/sdcard-automount.log
```

### Manual Testing
**Mount a partition:**
```bash
sudo systemctl start sdcard-automount@mmcblk0p9.service
```

**Unmount a partition:**
```bash
sudo systemctl stop sdcard-unmount@mmcblk0p9.service
```

## How It Works

### On SD Card Insertion
1. Udev detects new mmcblk partition
2. Triggers `sdcard-automount@{partition}.service`
3. Script checks if filesystem exists
4. If partition already mounted → unmounts first
5. Mounts partition to `/media/sdcard/{partition}/`
6. Makes accessible via symlink at `/home/pi/sdcard_data/`

### On SD Card Removal
1. Udev detects partition removal
2. Triggers systemd to stop `sdcard-unmount@{partition}.service`
3. Service executes `ExecStop` which runs unmount script
4. Script unmounts partition
5. Cleans up mount point directory

## Uninstallation

### Automatic Uninstallation (Recommended)

```bash
cd ~/TezSentinel/AutoMountSDCard
sudo ./uninstall.sh
```

The uninstaller will:
- Remove all installed components
- Stop running services
- Clean up configuration files
- Preserve logs for reference

### Manual Uninstallation

See the uninstall.sh script for detailed manual removal steps.

## Troubleshooting

### Check if services are running
```bash
systemctl status sdcard-automount@mmcblk0p9.service
systemctl status sdcard-unmount@mmcblk0p9.service
```

### Check udev rule is loaded
```bash
sudo udevadm control --reload-rules
udevadm test /sys/block/mmcblk0/mmcblk0p9
```

### Check current mounts
```bash
df -h | grep mmcblk
mount | grep sdcard
```

### View detailed logs
```bash
# Mount/unmount operations
cat /var/log/sdcard-automount.log

# Systemd journal
journalctl -u sdcard-automount@mmcblk0p9.service
journalctl -u sdcard-unmount@mmcblk0p9.service

# Udev events
journalctl -u systemd-udevd | grep sdcard
```

### Permission issues
If unmounting fails with permission errors:
```bash
# Verify sudoers file
sudo visudo -c
sudo cat /etc/sudoers.d/sdcard-automount
```

## Files Included

- `install.sh` - Automatic installer script
- `uninstall.sh` - Automatic uninstaller script
- `sdcard-automount.sh` - Main mount logic script
- `sdcard-unmount.sh` - Unmount helper script
- `sdcard-automount@.service` - Systemd mount service template
- `sdcard-unmount@.service` - Systemd unmount service template
- `99-sdcard-automount.rules` - Udev hotplug detection rule
- `sdcard-automount-sudoers` - Sudo permissions configuration
- `README.md` - This documentation

## Technical Details

### Supported Filesystems
- ext2, ext3, ext4
- FAT16, FAT32, exFAT
- NTFS
- Any filesystem with `blkid` detection

### Mount Point Structure
```
/media/sdcard/
├── mmcblk0p1/  (if has filesystem)
├── mmcblk0p8/  (rootfs partition)
└── mmcblk0p9/  (userdata partition)
```

### Security
- Scripts run with systemd (root privileges)
- Sudoers rule allows specific script only
- No password required for unmoun operation
- Mount points have 755 permissions

## Implementation Notes

- Developed and tested on NanoPi R76S running Linux 6.1
- Compatible with any Linux system using udev and systemd
- Handles multiple SD cards simultaneously
- Skips partitions without filesystems (boot loaders, etc.)
- Automatically cleans up stale mount points
- User-agnostic installation (works for any Linux user)

## License

This implementation is provided as-is for system administration purposes.

## Version History

- **v1.0** - Initial implementation with basic mount/unmount
- **v2.0** - Added systemd integration for reliable unmounting
- **v3.0** - Added intelligent remount capability when already mounted
- **v3.1** - Created automatic install/uninstall scripts with user detection

---
*Created: 2025-12-19*
*Last Updated: 2025-12-19*
