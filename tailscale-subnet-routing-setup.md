# Tailscale Subnet Routing Setup Guide

## ✅ Completed Steps

1. **Subnet Advertisement Configured**
   - Device: `bambooranch` (100.95.163.93)
   - Advertised Subnet: `192.168.1.0/24`
   - Command executed: `sudo tailscale up --advertise-routes=192.168.1.0/24 --accept-routes`

2. **IP Forwarding Enabled**
   - IPv4 forwarding: ✅ Already enabled
   - IPv6 forwarding: ✅ Enabled (added to `/etc/sysctl.conf`)

## 📋 Next Steps: Approve the Subnet Route

The subnet route has been **advertised** but needs to be **approved** in the Tailscale admin console.

### How to Approve:

1. **Open Tailscale Admin Console**
   - Visit: https://login.tailscale.com/admin/machines
   - Or use direct link: https://login.tailscale.com/admin/machines

2. **Find Your Device**
   - Look for: `bambooranch` (100.95.163.93)
   - Hostname: NanoPi-R76S

3. **Approve the Subnet Route**
   - Click the **three dots (⋮)** menu next to your device
   - Select **"Edit route settings..."**
   - You should see: `192.168.1.0/24` listed as an unapproved route
   - Click the toggle/checkbox to **approve** the route
   - Click **Save**

### Verification:

After approval, verify the route is active:

```bash
tailscale status
```

You should see other devices on your tailnet can now access devices on your `192.168.1.0/24` network through bambooranch.

## 🔍 Current Configuration Summary

- **Subnet Router**: bambooranch (NanoPi-R76S)
- **Tailscale IP**: 100.95.163.93
- **Local Network**: 192.168.1.0/24
- **Router IP**: 192.168.1.100
- **Accept Routes**: Enabled (can use routes from other subnet routers)

## 📝 Additional Information

### Testing Access After Approval

From any other device on your Tailscale network:

```bash
# Ping a device on the 192.168.1.0/24 network
ping 192.168.1.1

# Or access via browser
http://192.168.1.x
```

### Troubleshooting

If routes don't work after approval:

1. **Check firewall rules** on bambooranch:
   ```bash
   sudo iptables -L -v -n
   ```

2. **Verify IP forwarding** is still enabled:
   ```bash
   cat /proc/sys/net/ipv4/ip_forward    # Should be 1
   cat /proc/sys/net/ipv6/conf/all/forwarding  # Should be 1
   ```

3. **Restart Tailscale** if needed:
   ```bash
   sudo systemctl restart tailscaled
   ```

### Making Changes Persistent

The IP forwarding configuration has been added to `/etc/sysctl.conf` and will persist across reboots.

To modify advertised routes in the future:

```bash
# Add multiple subnets
sudo tailscale up --advertise-routes=192.168.1.0/24,172.18.0.0/16 --accept-routes

# Remove route advertisement
sudo tailscale up --advertise-routes= --accept-routes
```

## 📚 Reference

- Tailscale Subnet Routers: https://tailscale.com/kb/1019/subnets
- IP Forwarding: https://tailscale.com/s/ip-forwarding
