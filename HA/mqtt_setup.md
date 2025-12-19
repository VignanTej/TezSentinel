# Home Assistant MQTT Configuration (with Host Network Mode)

Since Home Assistant is running with `network_mode: host`, it can access the Mosquitto MQTT broker through the host's network interface.

## MQTT Broker Connection Details

When Home Assistant is in host network mode, use one of these addresses to connect to MQTT:

1. **localhost or 127.0.0.1** (Recommended)
   - Host: `localhost` or `127.0.0.1`
   - Port: `1883`
   - Username: `nodered`
   - Password: `NodeRED#123`

2. **Host's IP address** (For external access)
   - Host: `<your-host-ip>` (e.g., 192.168.1.100)
   - Port: `1883`
   - Username: `nodered`
   - Password: `NodeRED#123`

## Home Assistant Configuration

Add this to your Home Assistant `configuration.yaml`:

```yaml
# MQTT Configuration
mqtt:
  broker: localhost  # or 127.0.0.1
  port: 1883
  username: nodered
  password: NodeRED#123
  discovery: true
  discovery_prefix: homeassistant
```

Or configure through the UI:
1. Go to Settings → Devices & Services
2. Click "Add Integration"
3. Search for "MQTT"
4. Enter:
   - Broker: `localhost`
   - Port: `1883`
   - Username: `nodered`
   - Password: `NodeRED#123`

## Verify MQTT Connection

After configuring MQTT in Home Assistant:

1. Check the logs:
   ```bash
   docker logs homeassistant | grep -i mqtt
   ```

2. Test publishing from Home Assistant Developer Tools:
   - Go to Developer Tools → Services
   - Service: `mqtt.publish`
   - Topic: `test/hello`
   - Payload: `Hello from HA`

3. Test subscribing from command line:
   ```bash
   mosquitto_sub -h localhost -p 1883 \
     -u nodered -P "NodeRED#123" \
     -t "test/#" -v
   ```

## Frigate Integration

Since Frigate is now on the `tez-sentinel-net` network, it can communicate with MQTT using the container name. 

Add to Frigate's `config.yml`:

```yaml
mqtt:
  enabled: true
  host: mosquitto  # Uses container name within the network
  port: 1883
  user: nodered
  password: NodeRED#123
  topic_prefix: frigate
  client_id: frigate
  stats_interval: 60
```

## Node-RED Integration

Node-RED can connect to MQTT using the container name since they're in the same network:

In Node-RED MQTT nodes:
- Server: `mosquitto`
- Port: `1883`
- Username: `nodered`
- Password: `NodeRED#123`

## Network Architecture

```
Host Network
├── Home Assistant (network_mode: host)
│   └── Connects to MQTT via localhost:1883
│
Docker Bridge Network (tez-sentinel-net)
├── Node-RED (nodered)
│   └── Connects to MQTT via mosquitto:1883
├── Mosquitto (mosquitto)
│   └── Exposed ports: 1883, 9001
└── Frigate (frigate)
    └── Connects to MQTT via mosquitto:1883
```

## Benefits of This Setup

1. **Home Assistant** keeps full host network access for device discovery
2. **MQTT** is accessible from both host network and Docker network
3. **Frigate** and **Node-RED** can communicate via Docker network
4. All services can communicate through MQTT as a central hub

## Troubleshooting

### If Home Assistant can't connect to MQTT:

1. Verify Mosquitto is running:
   ```bash
   docker ps | grep mosquitto
   ```

2. Test connection from host:
   ```bash
   telnet localhost 1883
   ```

3. Check Mosquitto logs:
   ```bash
   docker logs mosquitto
   ```

### If Frigate can't connect to MQTT:

1. Verify both containers are on the same network:
   ```bash
   docker network inspect tez-sentinel-network
   ```

2. Test connectivity from Frigate container:
   ```bash
   docker exec frigate ping mosquitto