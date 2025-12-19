# TezSentinel

A comprehensive smart home and surveillance system running on NanoPi-R76S with Rockchip hardware acceleration. This repository contains the complete infrastructure for home automation, network video recording, and system utilities.

## 🏠 Overview

TezSentinel is a complete home automation and surveillance solution with:

- **Smart Home Hub** - Home Assistant for device integration and automation
- **Network Video Recorder** - Frigate NVR with Rockchip hardware acceleration
- **Automation Engine** - Node-RED for flow-based automation
- **MQTT Broker** - Mosquitto for reliable message passing
- **System Utilities** - Automated SD card management

## 📁 Repository Structure

```
.
├── AutoMountSDCard/      # SD card auto-mount utility
├── Frigate/              # Frigate NVR configuration
├── HA/                   # Home Assistant configuration
├── NR+MQTT/              # Node-RED and Mosquitto data
├── docker-compose.yaml   # Docker stack definition
├── DOCKER_STORAGE_FIX.md # Docker overlayfs troubleshooting
└── .gitignore            # Git ignore rules
```

## 🚀 Quick Start

### Prerequisites

- NanoPi-R76S or compatible Rockchip SBC
- Linux 6.1 or higher
- Docker and Docker Compose
- Minimum 4GB RAM recommended
- SD card or dedicated storage for recordings

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url> TezSentinel
   cd TezSentinel
   ```

2. **Start the Docker stack:**
   ```bash
   sudo docker compose up -d
   ```

3. **Access the services:**
   - Home Assistant: `http://<your-ip>:8123`
   - Frigate NVR: `http://<your-ip>:8971`
   - Node-RED: `http://<your-ip>:1880`
   - MQTT Broker: `<your-ip>:1883`

## 🔧 Components

### Docker Compose Stack

The main Docker Compose stack includes four integrated services:

#### 1. Frigate NVR
- **Purpose:** AI-powered Network Video Recorder with object detection
- **Image:** `ghcr.io/blakeblackshear/frigate:stable-rk` (Rockchip optimized)
- **Port:** 8971 (Web UI), 8554 (RTSP), 1984 (go2rtc API)
- **Features:**
  - Rockchip hardware acceleration (RGA, MPP)
  - Real-time object detection
  - Event recording and clips
  - RTSP stream support
- **Configuration:** [`Frigate/config/`](Frigate/)

#### 2. Home Assistant
- **Purpose:** Smart home integration and automation platform
- **Image:** `ghcr.io/home-assistant/home-assistant:stable`
- **Port:** 8123
- **Features:**
  - Device integration
  - Automation engine
  - Dashboard customization
  - Frigate integration
- **Configuration:** [`HA/config/`](HA/)

#### 3. Node-RED
- **Purpose:** Flow-based automation and integration
- **Image:** `nodered/node-red:latest`
- **Port:** 1880
- **Features:**
  - Visual programming interface
  - MQTT integration
  - Custom automation flows
  - Home Assistant integration
- **Configuration:** [`NR+MQTT/data/`](NR+MQTT/)

#### 4. Mosquitto MQTT
- **Purpose:** Message broker for IoT communication
- **Image:** `eclipse-mosquitto:latest`
- **Ports:** 1883 (MQTT), 9001 (WebSocket)
- **Features:**
  - Lightweight message broker
  - Reliable message delivery
  - WebSocket support
- **Configuration:** [`NR+MQTT/mosquitto/`](NR+MQTT/)

### AutoMountSDCard

Automatic SD card mounting and unmounting system for Linux using udev and systemd.

**Features:**
- ✅ Automatic mounting on SD card insertion
- ✅ Automatic unmounting on SD card removal
- ✅ Intelligent remount capability
- ✅ Comprehensive logging
- ✅ User-agnostic installation

**Documentation:** [`AutoMountSDCard/README.md`](AutoMountSDCard/README.md)

**Installation:**
```bash
cd AutoMountSDCard
sudo ./install.sh
```

## 🛠️ Configuration

### Docker Compose

The [`docker-compose.yaml`](docker-compose.yaml) file defines the entire stack with:
- Shared network (`tez-sentinel-net`) for inter-service communication
- Volume mounts for persistent data
- Hardware device access for Rockchip acceleration
- Health checks for service monitoring

### Environment Variables

Key environment variables in docker-compose:

- `TZ=Asia/Kolkata` - Timezone setting
- `FRIGATE_RTSP_PASSWORD` - RTSP stream password

### Networking

All services are connected via the `tez-sentinel-network` bridge network, enabling:
- MQTT communication between services
- Frigate integration with Home Assistant
- Node-RED automation flows

## 📊 Hardware Acceleration

This setup leverages Rockchip hardware acceleration for efficient video processing:

- **RGA** (Raster Graphic Acceleration) - Image scaling and format conversion
- **MPP** (Media Process Platform) - Hardware video encoding/decoding
- **VPU** (Video Processing Unit) - H.264/H.265 support

**Devices accessed:**
- `/dev/dri` - GPU/VPU access
- `/dev/dma_heap` - DMA heap for hardware acceleration
- `/dev/rga` - RGA unit
- `/dev/mpp_service` - MPP service

## 🐛 Troubleshooting

### Docker Storage Issues

If you encounter overlayfs errors, see the [`DOCKER_STORAGE_FIX.md`](DOCKER_STORAGE_FIX.md) guide.

**Quick fix:**
```bash
sudo apt-get install fuse-overlayfs
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "storage-driver": "fuse-overlayfs"
}
EOF
sudo systemctl restart docker
```

### Service Logs

View logs for any service:
```bash
# All services
sudo docker compose logs -f

# Specific service
sudo docker compose logs -f frigate
sudo docker compose logs -f homeassistant
sudo docker compose logs -f node-red
sudo docker compose logs -f mosquitto
```

### Service Management

```bash
# Start all services
sudo docker compose up -d

# Stop all services
sudo docker compose down

# Restart a specific service
sudo docker compose restart frigate

# View service status
sudo docker compose ps
```

## 🔒 Security

### Credentials
- Credentials are stored in service-specific configuration files
- `.gitignore` excludes sensitive files from version control
- MQTT and other passwords should be changed from defaults

### Network Security
- Tailscale provides encrypted access without exposing ports
- Services run in isolated Docker network
- Only necessary ports are exposed to host

### Excluded from Git
The `.gitignore` file protects:
- Storage and recordings
- Database files
- Secrets and credentials
- Log files
- Model cache
- Runtime files

## 📝 Maintenance

### Backups

Important directories to backup:
```bash
HA/config/          # Home Assistant configuration
Frigate/config/     # Frigate configuration
NR+MQTT/data/       # Node-RED flows
NR+MQTT/mosquitto/config/  # MQTT configuration
```

### Updates

Update all services:
```bash
sudo docker compose pull
sudo docker compose up -d
```

## 📚 Documentation

- **AutoMountSDCard:** [`AutoMountSDCard/README.md`](AutoMountSDCard/README.md)
- **Docker Storage Fix:** [`DOCKER_STORAGE_FIX.md`](DOCKER_STORAGE_FIX.md)

## 🖥️ System Requirements

**Hardware:**
- NanoPi-R76S or compatible Rockchip SBC
- Minimum 4GB RAM (8GB recommended)
- 32GB+ storage for OS and applications
- Separate storage for recordings (SD card, USB drive, or NAS)

**Software:**
- Operating System: Linux 6.1+
- Docker Engine: 20.10+
- Docker Compose: 2.0+

## 🔗 Useful Links

- [Home Assistant Documentation](https://www.home-assistant.io/docs/)
- [Frigate Documentation](https://docs.frigate.video/)
- [Node-RED Documentation](https://nodered.org/docs/)
- [Mosquitto Documentation](https://mosquitto.org/documentation/)
- [Tailscale Documentation](https://tailscale.com/kb/)

## 📄 License

This project is configured for personal use. Individual components are licensed under their respective licenses:
- Home Assistant: Apache License 2.0
- Frigate: MIT License
- Node-RED: Apache License 2.0
- Mosquitto: EPL/EDL

## 👤 Author

**Tez Solutions**
- Device: NanoPi-R76S (bambooranch)
- Location: Asia/Kolkata
- Network: 192.168.1.0/24

---

*Last Updated: 2025-12-19*
