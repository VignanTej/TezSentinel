# Node-RED Docker Compose Stack

This Docker Compose setup includes Node-RED and Mosquitto MQTT broker with persistent local storage.

## Stack Components

1. **Node-RED**: A flow-based programming tool for the Internet of Things
   - URL: http://localhost:1880
   - Container name: `nodered`
   - Data persisted in: `./data`

2. **Mosquitto MQTT Broker**: Lightweight message broker
   - MQTT Port: 1883
   - WebSockets Port: 9001
   - Container name: `mosquitto`
   - Data persisted in: `./mosquitto/data`
   - Config: `./mosquitto/config/mosquitto.conf`
   - Logs: `./mosquitto/log`

## Network Configuration

- Network name: `tez-sentinel-net`
- Actual Docker network name: `tez-sentinel-network`
- Subnet: Default Docker bridge network

## MQTT Authentication

- **Username**: `nodered`
- **Password**: `NodeRED#123`

## Starting the Stack

```bash
cd NR
docker compose up -d
```

## Stopping the Stack

```bash
cd NR
docker compose down
```

## Viewing Logs

```bash
# All logs
docker compose logs

# Node-RED logs
docker compose logs node-red

# Mosquitto logs
docker compose logs mosquitto
```

## Connecting to MQTT from Another Container

### Option 1: Add to the Same Compose File

Add your service to the `compose.yaml`:

```yaml
services:
  # Existing services...
  
  your-service:
    image: your-image
    container_name: your-container
    networks:
      - tez-sentinel-net
    environment:
      - MQTT_BROKER=mosquitto
      - MQTT_PORT=1883
      - MQTT_USERNAME=nodered
      - MQTT_PASSWORD=NodeRED#123
```

### Option 2: Connect from External Container

For a container in a different compose file, add this to your compose file:

```yaml
services:
  your-service:
    image: your-image
    networks:
      - your-network
      - tez-sentinel-net

networks:
  your-network:
    # your network config
  tez-sentinel-net:
    external: true
    name: tez-sentinel-network
```

### Connection Examples

#### Node.js (using mqtt.js)

```javascript
const mqtt = require('mqtt');

const client = mqtt.connect({
  host: 'mosquitto',
  port: 1883,
  username: 'nodered',
  password: 'NodeRED#123',
  protocol: 'mqtt'
});

client.on('connect', () => {
  console.log('Connected to MQTT broker');
  client.subscribe('test/topic');
  client.publish('test/topic', 'Hello from Node.js');
});

client.on('message', (topic, message) => {
  console.log(`Received: ${topic} - ${message.toString()}`);
});
```

#### Python (using paho-mqtt)

```python
import paho.mqtt.client as mqtt

def on_connect(client, userdata, flags, rc):
    print(f"Connected with result code {rc}")
    client.subscribe("test/topic")

def on_message(client, userdata, msg):
    print(f"Received: {msg.topic} - {msg.payload.decode()}")

client = mqtt.Client()
client.username_pw_set("nodered", "NodeRED#123")
client.on_connect = on_connect
client.on_message = on_message

# Connect using container name when in same network
client.connect("mosquitto", 1883, 60)

client.publish("test/topic", "Hello from Python")
client.loop_forever()
```

#### Docker Run Example

To run a one-off container connected to the network:

```bash
docker run --rm -it \
  --network tez-sentinel-network \
  alpine/mosquitto-clients \
  mosquitto_sub -h mosquitto -p 1883 \
  -u nodered -P "NodeRED#123" \
  -t "test/topic" -v
```

## Testing MQTT Connection

### Using Docker

```bash
# Subscribe to a topic
docker run --rm -it \
  --network tez-sentinel-network \
  alpine/mosquitto-clients \
  mosquitto_sub -h mosquitto -p 1883 \
  -u nodered -P "NodeRED#123" \
  -t "test/#" -v

# Publish to a topic (in another terminal)
docker run --rm -it \
  --network tez-sentinel-network \
  alpine/mosquitto-clients \
  mosquitto_pub -h mosquitto -p 1883 \
  -u nodered -P "NodeRED#123" \
  -t "test/hello" -m "Hello World"
```

### From Host Machine

```bash
# Install mosquitto clients (if not installed)
sudo apt-get install mosquitto-clients

# Subscribe
mosquitto_sub -h localhost -p 1883 \
  -u nodered -P "NodeRED#123" \
  -t "test/#" -v

# Publish
mosquitto_pub -h localhost -p 1883 \
  -u nodered -P "NodeRED#123" \
  -t "test/hello" -m "Hello World"
```

## Checking Container Status

```bash
# View running containers
docker compose ps

# Check network details
docker network inspect tez-sentinel-network
```

## Adding More Users to Mosquitto

1. Edit the password file:
```bash
echo "newuser:newpassword" >> mosquitto/config/password.txt
```

2. Hash the password file:
```bash
docker compose exec mosquitto mosquitto_passwd -U /mosquitto/config/password.txt
```

3. Restart Mosquitto:
```bash
docker compose restart mosquitto
```

## Troubleshooting

### Permission Issues
If Node-RED fails to start with permission errors:
```bash
sudo chown -R 1000:1000 data/
docker compose restart node-red
```

### Network Issues
If containers can't connect to each other:
1. Verify they're on the same network:
```bash
docker network inspect tez-sentinel-network
```

2. Check container names:
```bash
docker compose ps
```

3. Test connectivity:
```bash
docker compose exec node-red ping mosquitto
```

## Security Notes

1. Change default passwords before production use
2. Consider using TLS/SSL for MQTT connections
3. Implement proper authentication and ACL rules
4. Use environment variables or secrets for passwords
5. Regularly update Docker images

## Backup and Restore

### Backup
```bash
tar -czf nodered-backup.tar.gz data/ mosquitto/
```

### Restore
```bash
tar -xzf nodered-backup.tar.gz
docker compose up -d