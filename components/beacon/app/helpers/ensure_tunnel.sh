#!/usr/bin/env bash
set -eEuo pipefail
source /app/helpers/functions.sh

tunnel_name=$1
tunnel_secret=$2
tunnel_secret_base64=$(
  echo "$tunnel_secret" | base64
)

tunnel_dns_name="${tunnel_name}.${USVA_DOMAIN}"

tunnel_id=""
for ((i=0; i<3; i++)); do
  _echoerr "list $tunnel_name"

  tunnel_id=$(cloudflared tunnel --no-autoupdate list --output json --name "$tunnel_name" | jq -r ".[0].id" || true)
  [[ "$tunnel_id" != "null" ]] && [[ "$tunnel_id" != "" ]] && break

  1>&2 cloudflared tunnel --no-autoupdate create \
    --secret "$tunnel_secret_base64" \
    "$tunnel_name" || true

  tunnel_id=""
done

if [[ "$tunnel_id" == "" ]]; then
  _err "failed to ensure tunnel"
fi

_echoerr "tunnel_id: $tunnel_id"

ok=no
for ((i=0; i<3; i++)); do
  if 1>&2 cloudflared tunnel --no-autoupdate --overwrite-dns route dns "$tunnel_name" "$tunnel_dns_name"; then
    ok=yes
    break
  fi
  sleep 0.1
done

if [[ "$ok" == "no" ]]; then
  _err "failed to update dns for $tunnel_dns_name"
fi

echo """{
  \"AccountTag\": \"$CLOUDFLARE_ACCOUNT_TAG\",
  \"TunnelSecret\": \"$tunnel_secret_base64\",
  \"TunnelID\": \"$tunnel_id\"
}""" | tee "$HOME/.cloudflared/${tunnel_id}.json"
