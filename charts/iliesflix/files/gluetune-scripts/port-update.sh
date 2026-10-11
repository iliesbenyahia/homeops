echo "===== port-update.sh DEBUG ====="
echo "date: $(date)"
echo "args count: $#"
echo "arg1: [$1]"
echo "arg2: [$2]"
echo "PORT env: [$PORT]"
echo "VPN_INTERFACE env: [$VPN_INTERFACE]"
echo "==============================="

PORT="$1"
VPN_INTERFACE="$2"

echo "PORT after assignment: [$PORT]"
echo "VPN_INTERFACE after assignment: [$VPN_INTERFACE]"

wget -O- -nv --retry-connrefused \
  --post-data \
  "json={\"listen_port\":${PORT},\"current_network_interface\":\"${VPN_INTERFACE}\",\"random_port\":false,\"upnp\":false}" \
  http://127.0.0.1:8080/api/v2/app/setPreferences

echo "Checking qBittorrent preferences..."
wget -qO- \
  http://127.0.0.1:8080/api/v2/app/preferences