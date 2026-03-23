#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${1:-4173}"
BUILD_DIR="${HANZI_EXPORT_DIR:-${ROOT_DIR}/build}"
AUTO_EXPORT="${AUTO_EXPORT:-1}"

detect_lan_ip() {
  local candidate=""
  for iface in en0 en1; do
    candidate="$(ipconfig getifaddr "$iface" 2>/dev/null || true)"
    if [[ -n "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  candidate="$(ifconfig 2>/dev/null | awk '/inet / && $2 != "127.0.0.1" { print $2; exit }')"
  if [[ -n "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  return 1
}

if [[ "$AUTO_EXPORT" != "0" ]]; then
  "${ROOT_DIR}/scripts/export_web.sh"
elif [[ ! -f "${BUILD_DIR}/index.html" ]]; then
  printf 'No exported build found at %s/index.html. Run ./scripts/export_web.sh first or omit AUTO_EXPORT=0.\n' "$BUILD_DIR" >&2
  exit 1
fi

LAN_IP="${LAN_IP:-$(detect_lan_ip || true)}"
LOCAL_BASE="http://localhost:${PORT}"

printf 'Serving exported Godot web build from %s\n' "$BUILD_DIR"
printf 'Local URL:\n'
printf '  %s/index.html\n' "$LOCAL_BASE"

if [[ -n "$LAN_IP" ]]; then
  printf 'LAN URL:\n'
  printf '  http://%s:%s/index.html\n' "$LAN_IP" "$PORT"
else
  printf 'LAN IP could not be detected automatically. The preview server will still bind to 0.0.0.0.\n'
fi

printf 'Set AUTO_EXPORT=0 to reuse the current build without re-exporting.\n'
printf 'Press Ctrl+C to stop the server.\n'

cd "$BUILD_DIR"
exec python3 -m http.server "$PORT" --bind 0.0.0.0
