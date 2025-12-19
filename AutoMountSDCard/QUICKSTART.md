# Quick Start Guide

## Installation

```bash
cd ~/TezSentinel/AutoMountSDCard
sudo ./install.sh
```

## Usage

### Access your SD card data:
```bash
ls ~/sdcard_data/
```

### View logs:
```bash
tail -f /var/log/sdcard-automount.log
```

## Uninstallation

```bash
cd ~/TezSentinel/AutoMountSDCard
sudo ./uninstall.sh
```

## How it Works

1. **Insert SD card** → Auto-mounts to `~/sdcard_data/`
2. **Access data** → All partitions appear as subdirectories
3. **Remove SD card** → Automatically unmounts

## Troubleshooting

**SD card not mounting?**
```bash
# Check logs
tail /var/log/sdcard-automount.log

# Check if SD card is detected
lsblk -f
```

**Already installed?**
The installer will automatically handle existing mounts and reinstall cleanly.

For full documentation, see [README.md](README.md)
