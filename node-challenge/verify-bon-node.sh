#!/usr/bin/env bash
set -euo pipefail

node_dir="${HOME}/elrond-nodes/node-0"
service_name="elrond-node-0"
heartbeat_url="http://127.0.0.1:8080/node/heartbeatstatus"
status_url="http://127.0.0.1:8080/node/status"

echo "[service]"
systemctl is-active "$service_name" || true
systemctl --no-pager --full status "$service_name" | sed -n '1,20p' || true

echo
echo "[version/logs]"
if [[ -d "${node_dir}/logs" ]]; then
  if command -v rg >/dev/null 2>&1; then
    rg -n "v1\.11\.0\.3-bon|trie sync in progress|processed|header|block" "${node_dir}/logs" -S | tail -n 40 || true
  else
    grep -rE "v1\.11\.0\.3-bon|trie sync in progress|processed|header|block" "${node_dir}/logs" | tail -n 40 || true
  fi
else
  echo "logs dir not found: ${node_dir}/logs"
fi

echo
echo "[heartbeat]"
curl -sf "$heartbeat_url" || true

echo
echo
echo "[status]"
curl -sf "$status_url" || true

echo
echo
echo "Manual checks:"
echo "- Heartbeat should mention version v1.11.0.3-bon."
echo "- Logs should show trie sync progress and later block processing."
echo "- Status should show the node running and catching up or synced."
