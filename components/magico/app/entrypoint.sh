#!/usr/bin/env bash
set -eEuo pipefail

_on_error() {
  trap '' ERR
  line_path=$(caller)
  line=${line_path% *}
  path=${line_path#* }

  echo ""
  echo "ERR $path:$line $BASH_COMMAND exited with $1"
  _shutdown 1
}
trap '_on_error $?' ERR

_shutdown() {
  trap '' TERM INT
  echo "shutdown: $1"

  kill 0
  wait
  exit 0
}
trap '_shutdown 0' TERM INT

case "${1:-}" in
  hang)
    echo "HANG"
    tail -f /dev/null & wait
    exit 0
  ;;
esac

echo "magico start"

mkdir "${HOME}/.cloudflared"

envsubst -i /app/tunnel.template.json -o "${HOME}/.cloudflared/${CLOUDFLARE_TUNNEL_ID}.json"

tailer /tmp/chisel.log:chisel /tmp/cloudflared.log:cloudflared &

(
  exec chisel server -v --auth magico:sekret
) >/tmp/chisel.log 2>&1 &

(
  exec cloudflared tunnel --no-autoupdate run --url "http://127.0.0.1:8080" "$CLOUDFLARE_TUNNEL_ID"
) >/tmp/cloudflared.log 2>&1 &

wait -n || true

echo "something exited!"

sleep 5
_shutdown 1
