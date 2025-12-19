# Frigate Docker Setup for Rockchip SBC

This repository contains Docker configuration files for running Frigate on a Rockchip-based Single Board Computer (SBC).

## Prerequisites

### 1. Verify Rockchip Hardware Support

Before starting, ensure your system has the required Rockchip drivers and kernel:

```bash
# Check kernel version (should be 5.10.xxx-rockchip or 6.1.xxx-rockchip)
uname -r

# Check for required devices
ls /dev/dri
# Should show: by-path card0 card1 renderD128 renderD129

# Check RKNPU driver version
sudo cat /sys/kernel/debug/rknpu/version
# Should show: RKNPU driver: v0.9.2 or later
```

### 2. Recommended OS

- **Armbian** (if your board is supported): https://www.armbian.com/download/?arch=aarch64
- Any Linux distribution with Rockchip BSP kernel 5.10 or 6.1

## Setup Instructions

### 1. Clone or Download Files

Ensure you have these files in your project directory:
- `Dockerfile`
- `docker-compose.yaml`
- `config.yml`

### 2. Create Required Directories

```bash
mkdir -p config storage
```

### 3. Configure Frigate

1. Copy the example configuration:
   ```bash
   cp config.yml config/config.yml
   ```

2. Edit `config/config.yml` to match your setup:
   - Replace camera URLs with your actual camera streams
   - Adjust detection zones and object filters
   - Configure MQTT if needed

### 4. Start Frigate

#### Option A: Using Docker Compose (Recommended)

```bash
# Start in privileged mode for initial setup
docker-compose up -d

# Check logs
docker-compose logs -f frigate
```

#### Option B: Using Docker Run

```bash
docker run -d \
  --name frigate \
  --restart=unless-stopped \
  --stop-timeout 30 \
  --security-opt systempaths=unconfined \
  --security-opt apparmor=unconfined \
  --device /dev/dri \
  --device /dev/dma_heap \
  --device /dev/rga \
  --device /dev/mpp_service \
  --volume /sys/:/sys/:ro \
  --volume ./config:/config \
  --volume ./storage:/media/frigate \
  --volume /etc/localtime:/etc/localtime:ro \
  --mount type=tmpfs,target=/tmp/cache,tmpfs-size=1000000000 \
  --shm-size=512m \
  -p 8971:8971 \
  -p 8554:8554 \
  -p 8555:8555/tcp \
  -p 8555:8555/udp \
  -e FRIGATE_RTSP_PASSWORD='password' \
  ghcr.io/blakeblackshear/frigate:stable-rk
```

### 5. Access Frigate

- Web UI: http://your-sbc-ip:8971
- RTSP streams: rtsp://your-sbc-ip:8554/camera_name

## Security Hardening

After confirming everything works with `privileged: true`, you can improve security:

1. Edit `docker-compose.yaml`
2. Change `privileged: true` to `privileged: false`
3. The specific device mappings and security options are already configured

## Configuration Tips

### Hardware Acceleration

The configuration uses Rockchip-specific hardware acceleration:
- **Object Detection**: RKNN (Rockchip Neural Network) accelerator
- **Video Processing**: Rockchip VPU for encoding/decoding

### Performance Tuning

1. **Shared Memory**: Adjust `shm_size` based on your cameras:
   ```
   shm_size = (width × height × 1.5 × fps × number_of_cameras) / 1024 / 1024
   ```

2. **Detection Settings**: 
   - Lower FPS for detection (5 fps is usually sufficient)
   - Use substreams for detection, main streams for recording

3. **Storage**: 
   - Use fast storage (SSD) for better performance
   - Configure retention policies to manage disk space

### Camera Configuration

Replace the example camera in `config/config.yml`:

```yaml
cameras:
  your_camera_name:
    ffmpeg:
      inputs:
        - path: rtsp://username:password@camera_ip:554/main_stream
          roles:
            - record
        - path: rtsp://username:password@camera_ip:554/sub_stream
          roles:
            - detect
    detect:
      width: 640   # Use substream resolution
      height: 480
      fps: 5
```

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure Docker has access to hardware devices
2. **High CPU Usage**: Check if hardware acceleration is working
3. **Camera Connection Issues**: Verify RTSP URLs and credentials

### Useful Commands

```bash
# Check container logs
docker-compose logs frigate

# Check hardware acceleration
docker exec frigate cat /proc/version

# Monitor resource usage
docker stats frigate

# Restart container
docker-compose restart frigate
```

### Hardware Verification

```bash
# Check if VPU is accessible
ls -la /dev/dri/

# Check NPU status
cat /sys/kernel/debug/rknpu/version

# Monitor hardware usage
sudo iotop
```

## Additional Resources

- [Frigate Documentation](https://docs.frigate.video/)
- [Rockchip Platform Guide](https://docs.frigate.video/frigate/installation/#rockchip-platform)
- [Hardware Acceleration](https://docs.frigate.video/configuration/hardware_acceleration_video#rockchip-platform)
- [Object Detection Configuration](https://docs.frigate.video/configuration/object_detectors#rockchip-platform)

## Support

If you encounter issues:
1. Check the [Frigate GitHub Discussions](https://github.com/blakeblackshear/frigate/discussions)
2. Verify your hardware meets the requirements
3. Review the logs for specific error messages