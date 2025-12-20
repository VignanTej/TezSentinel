# TezSentinel Landing Page Setup ✅

## Overview

A simple nginx landing page that provides easy access to all TezSentinel services from your Tailscale network.

## Access the Dashboard

From any device on your Tailscale network, open:
- **`http://bambooranch/`** - TezSentinel Service Dashboard

The landing page provides clickable links to all services with their correct ports.

## Available Services

| Service | URL | Port |Description |
|---------|-----|------|------------|
| **Frigate NVR** | `https://bambooranch:8971` | 8971 | Camera surveillance with HTTPS |
| **Home Assistant** | `http://bambooranch:8123` | 8123 | Smart home control |
| **Node-RED** | `http://bambooranch:1880` | 1880 | Flow-based automation |
| **Mosquitto MQTT** | `http://bambooranch:9001` | 9001 | MQTT WebSocket |

## What Was Configured

### 1. Landing Page HTML
- Created [`nginx/html/index.html`](nginx/html/index.html) - Beautiful dashboard with service cards
- Responsive design that works on mobile and desktop
- Direct links to each service with proper ports

### 2. Nginx Configuration
- [`nginx/conf.d/default.conf`](nginx/conf.d/default.conf) - Simplified to serve static HTML
- No reverse proxy complexity - just direct links to services
- Health check endpoint at `/health`

### 3. Docker Compose
- [`docker-compose.yaml`](docker-compose.yaml) - Updated nginx service with HTML volume mount
- Container runs on port 80
- Automatically starts with other services

### 4. Frigate Configuration
- [`Frigate/config/config.yml`](Frigate/config/config.yml) - Has base_path configured (not needed for landing page approach, but kept for reference)

## Files Structure

```
TezSentinel/nginx/
├── nginx.conf                 # Main nginx configuration
├── conf.d/
│   └── default.conf          # Static file server config
├── html/
│   └── index.html            # Landing page dashboard
├── logs/                     # Nginx access and error logs
├── .gitignore               # Excludes log files
└── README.md                # Original nginx documentation
```

## Managing the Landing Page

### View the Landing Page
```bash
# From local machine
curl http://localhost/

# Check status
sudo docker ps --filter name=nginx
```

### Update the Landing Page
1. Edit `nginx/html/index.html`
2. No restart needed - changes are immediate (volume mounted)

### Restart Nginx
```bash
sudo docker restart nginx-proxy
```

### View Logs
```bash
sudo docker logs nginx-proxy -f
```

### Recreate Container (after config changes)
```bash
cd TezSentinel
sudo docker compose up -d nginx
```

## Features

✅ **Clean Design** - Modern, responsive interface  
✅ **Direct Access** - No reverse proxy complexity  
✅ **Service Cards** - Easy to identify each service  
✅ **Mobile Friendly** - Works on phones and tablets  
✅ **Port Display** - Shows the actual URL and port for each service  
✅ **Security Info** - Displays authentication requirements  
✅ **Health Check** - Built-in endpoint for monitoring  

## Security Notes

- **Frigate**: Uses HTTPS with self-signed certificate (you'll see a browser warning - this is normal)
- **Home Assistant**: Has built-in authentication - login required
- **Node-RED**: Should configure authentication in settings
- **Mosquitto**: MQTT connections require username/password

## Troubleshooting

### Landing Page Not Loading
```bash
# Check nginx is running
sudo docker ps --filter name=nginx

# Check nginx logs
sudo docker logs nginx-proxy

# Restart nginx
sudo docker restart nginx-proxy
```

### Can't Access Services from Landing Page
- Verify the service is running: `sudo docker ps`
- Check the port numbers match: Services use their original ports
- Ensure your device is connected to Tailscale network
- Try accessing the service directly (bypass landing page)

### Update Not Showing
- HTML changes are immediate (no restart needed)
- Clear browser cache (Ctrl+F5 or Cmd+Shift+R)
- Check file permissions: `ls -la nginx/html/`

## Benefits of This Approach

1. **Simplicity** - No complex reverse proxy configuration
2. **Reliability** - Services work on their native ports
3. **Flexibility** - Easy to add/remove services
4. **Performance** - Direct connections to services
5. **Debugging** - Easier to troubleshoot issues
6. **Compatibility** - Works with services that don't support subfolder paths

## Future Enhancements

Possible improvements:
- Add service status indicators (online/offline)
- Include service icons/logos
- Add dark mode toggle
- Display recent activity or stats
- Add quick action buttons
- Include documentation links

## Original Port Mapping

For reference, the services are accessible on these ports:
- Nginx landing page: `80`
- Home Assistant: `8123`
- Node-RED: `1880`
- MQTT WebSocket: `9001`
- Frigate HTTPS: `8971`
- Frigate RTSP: `8554`
- Frigate WebRTC: `8555`
- Frigate go2rtc: `1984`

All services are accessible through the Tailscale network using the `bambooranch` hostname! 🎉
