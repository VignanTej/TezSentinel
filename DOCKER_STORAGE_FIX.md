# Docker Storage Driver Fix for Overlayfs on Overlayfs

## Issue
When running Docker on a system where the root filesystem is already using overlayfs (common in some Raspberry Pi/NanoPi setups), you may encounter this error:

```
failed to convert whiteout file "home/.wh.node": operation not permitted
```

This happens because Docker's overlayfs driver cannot properly handle whiteout files when running on top of an existing overlayfs filesystem.

## Solutions

### Option 1: Use Fuse-Overlayfs (Recommended)
Install and configure fuse-overlayfs storage driver:

```bash
# Install fuse-overlayfs
sudo apt-get update
sudo apt-get install fuse-overlayfs

# Configure Docker to use it
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "storage-driver": "fuse-overlayfs"
}
EOF

# Restart Docker
sudo systemctl restart docker

# Start the containers
cd /home/pi/TezSentinel
sudo docker compose up -d
```

### Option 2: Use VFS Storage Driver (Simple but slower)
VFS doesn't use copy-on-write, so it's slower and uses more disk space, but it works:

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "storage-driver": "vfs"
}
EOF

sudo systemctl restart docker
cd /home/pi/TezSentinel
sudo docker compose up -d
```

### Option 3: Pull Images on a Different System
If you have another Linux system with proper overlayfs support:

1. Pull and save the images on that system:
```bash
docker pull nodered/node-red:latest
docker pull ghcr.io/home-assistant/home-assistant:stable
docker pull ghcr.io/blakeblackshear/frigate:stable-rk
docker pull eclipse-mosquitto:latest

docker save -o images.tar \
  nodered/node-red:latest \
  ghcr.io/home-assistant/home-assistant:stable \
  ghcr.io/blakeblackshear/frigate:stable-rk \
  eclipse-mosquitto:latest
```

2. Transfer `images.tar` to your NanoPi and load them:
```bash
sudo docker load -i images.tar
cd /home/pi/TezSentinel
sudo docker compose up -d
```

## Current System Info
- OS: Linux 6.1 (NanoPi-R76S)
- Root FS: overlayfs
- Current Docker Storage Driver: overlayfs

## Recommendation
For your NanoPi-R76S system, I recommend **Option 1 (fuse-overlayfs)** as it provides the best balance of performance and compatibility.
