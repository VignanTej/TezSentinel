# Nginx Reverse Proxy Configuration

This nginx reverse proxy enables access to TezSentinel services from the Tailscale network using MagicDNS with subfolder paths.

## 📋 Overview

The nginx proxy provides centralized access to all services running in the TezSentinel stack through a single entry point on port 80.

## 🌐 Service Endpoints

Access services using the Tailscale MagicDNS hostname followed by the service subfolder:

- **Frigate NVR**: `http://bambooranch/frigate/`
  - Web UI for camera surveillance and recording
  - Port: 5000 (proxied through nginx)

- **Home Assistant**: `http://bambooranch/homeassistant/`
  - Smart home automation hub
  - Port: 8123 (proxied through nginx via host network)

- **Node-RED**: `http://bambooranch/nodered/`
  - Flow-based automation platform
  - Port: 1880 (proxied through nginx)

- **Mosquitto MQTT**: `http://bambooranch/mosquitto/`
  - MQTT WebSocket interface
  - Port: 9001 (proxied through nginx)

- **Health Check**: `http://bambooranch/health`
  - Nginx health status endpoint

## 🔧 Configuration Files

```
nginx/
├── nginx.conf              # Main nginx configuration
├── conf.d/
│   └── default.conf       # Reverse proxy rules for all services
├── logs/                  # Nginx access and error logs
└── README.md             # This file
```

## 🚀 Features

### WebSocket Support
All services are configured with WebSocket support for real-time bidirectional communication:
- Frigate: Live camera streams
- Home Assistant: Real-time state updates
- Node-RED: Dashboard updates
- Mosquitto: MQTT over WebSocket

### Subfolder Routing
Each service is accessible via a unique subfolder path, making it easy to organize and access multiple services through a single domain.

### Host Network Access
Home Assistant runs in host network mode, so nginx uses `host.docker.internal` to access it on port 8123.

### Buffer Optimization
Increased buffer sizes for handling large responses from Home Assistant and other services:
```nginx
proxy_buffer_size   128k;
proxy_buffers   4 256k;
proxy_busy_buffers_size   256k;
client_max_body_size 100M;
```

## 🔌 Network Architecture

```
Tailscale Network (MagicDNS: bambooranch)
           ↓
    Nginx Proxy (Port 80)
           ↓
    ┌──────┴──────┬──────────┬──────────┐
    ↓             ↓          ↓          ↓
  Frigate    Node-RED   Mosquitto   Home Assistant
  (5000)     (1880)     (9001)      (host:8123)
```

## 📝 Usage

### Starting the Proxy

The nginx proxy starts automatically with the docker-compose stack:

```bash
cd TezSentinel
docker-compose up -d nginx
```

### Accessing from Tailscale Network

From any device connected to your Tailscale network:

```bash
# Access Frigate NVR
http://bambooranch/frigate/

# Access Home Assistant
http://bambooranch/homeassistant/

# Access Node-RED
http://bambooranch/nodered/

# Access Mosquitto WebSocket
http://bambooranch/mosquitto/
```

### Viewing Logs

```bash
# Real-time access logs
docker-compose logs -f nginx

# Or directly from log files
tail -f nginx/logs/access.log
tail -f nginx/logs/error.log
```

### Health Check

```bash
curl http://bambooranch/health
# Returns: healthy
```

## 🔍 Troubleshooting

### Service Not Accessible

1. **Check nginx container status**:
   ```bash
   docker-compose ps nginx
   ```

2. **Check nginx logs for errors**:
   ```bash
   docker-compose logs nginx
   ```

3. **Verify target service is running**:
   ```bash
   docker-compose ps
   ```

4. **Test internal connectivity**:
   ```bash
   docker-compose exec nginx wget -O- http://frigate:5000
   ```

### Home Assistant 400 Bad Request

If you get a 400 error accessing Home Assistant:

1. Add the Tailscale hostname to Home Assistant's trusted proxies
2. Edit `HA/config/configuration.yaml`:
   ```yaml
   http:
     use_x_forwarded_for: true
     trusted_proxies:
       - 172.18.0.0/16  # Docker network
   ```

### WebSocket Connection Issues

1. Verify WebSocket upgrade headers in nginx logs
2. Check for any connection timeout errors
3. Ensure services support WebSocket connections

## 🔐 Security Notes

- The proxy is accessible from the entire Tailscale network
- Consider adding authentication at the nginx level for additional security
- Home Assistant has built-in authentication
- Node-RED should have authentication enabled in settings
- Frigate can be configured with authentication in its config

## 🎯 Future Enhancements

Potential improvements:
- Add SSL/TLS certificates for HTTPS
- Implement basic auth for non-authenticated services
- Add rate limiting
- Configure access logging per service
- Add custom error pages
- Implement IP-based access restrictions

## 📚 References

- [Nginx Reverse Proxy Documentation](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [Tailscale MagicDNS](https://tailscale.com/kb/1081/magicdns/)
- [Docker Networking](https://docs.docker.com/network/)
