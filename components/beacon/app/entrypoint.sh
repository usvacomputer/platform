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
  exit "$1"
}
trap '_shutdown 0' TERM INT

subcommand="${1:-server}"

case "$subcommand" in
  hang)
    echo "hang"
    tail -f /dev/null & wait
  ;;
  server)
    (
      tunnel_name="${USVA_ENV}-beacon"
      tunnel_secret="${USVA_ENV}-beacon-adsjfaisdofjdisoafjioadsfjifdjsfdsffaaa"
      tunnel_dns_name="${tunnel_name}.${USVA_DOMAIN}"
      tunnel_json=$(
        /app/helpers/ensure_tunnel.sh "$tunnel_name" "$tunnel_secret" "$tunnel_dns_name"
      )
      tunnel_id=$(
        echo "$tunnel_json" | jq -r '.TunnelID'
      )
      echo "$tunnel_json" > "$HOME/.cloudflared/${tunnel_id}.json"

      exec cloudflared tunnel --no-autoupdate run --url http://127.0.0.1:8080 "$tunnel_id"
    ) >/tmp/cloudflared.log 2>&1 &

    exec reflex -v -t 3s -s ruby /app/beacon.rb
  ;;
  *)
    echo "unknown subcommand: $subcommand"
    _shutdown 1
  ;;
esac
