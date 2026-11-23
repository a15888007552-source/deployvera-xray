#!/bin/sh
# Generate xray config from environment and run it.
# Env vars (set in the DeployVera panel; UUID/WS_PATH fall back to generated values):
#   PORT     - port the platform assigns (required; DeployVera sets this)
#   UUID     - VLESS client UUID (generated if unset; printed to the log)
#   WS_PATH  - WebSocket path (default /vless)
set -e

PORT="${PORT:-8080}"

if [ -z "$UUID" ]; then
  UUID="$(cat /proc/sys/kernel/random/uuid)"
  echo "UUID not set; generated UUID: $UUID"
else
  echo "Using provided UUID."
fi

WS_PATH="${WS_PATH:-/vless}"
echo "Listening on port $PORT, WS path $WS_PATH"

mkdir -p /etc/xray
cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "$UUID", "flow": "" } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "$WS_PATH" }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "blocked" }
  ]
}
EOF

exec ${XRAY_BIN:-/usr/local/bin/xray} -config /etc/xray/config.json
