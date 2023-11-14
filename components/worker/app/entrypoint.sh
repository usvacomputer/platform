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

subcommand="${1:-}"
case "$subcommand" in
  hang)
    echo "hang"
    tail -f /dev/null & wait
  ;;
esac

echo "usva worker starting..."

ifconfig lo:20 10.20.30.40 netmask 255.255.255.0 up

while true; do
  curl -Lsf --max-time 15 -o /dev/null "https://${USVA_ENV}-beacon.${USVA_DOMAIN}/v1/cluster/${USVA_NAME}/kubeconfig" && break
  sleep 1
done
echo "got cluster"

while true; do
  curl -Lsf --max-time 15 -o /dev/null "https://${USVA_ENV}-beacon.${USVA_DOMAIN}/v1/cluster/${USVA_NAME}/magico" && break
  sleep 1
done
echo "got magico"

while true; do
  curl -Lsf --max-time 15 -o /jointoken "https://${USVA_ENV}-beacon.${USVA_DOMAIN}/v1/cluster/${USVA_NAME}/jointoken" && break
  sleep 1
done
echo "got jointoken"

while true; do
  curl -Lsf --max-time 15 -o /chisel.sh "https://${USVA_ENV}-beacon.${USVA_DOMAIN}/v1/cluster/${USVA_NAME}/chisel.sh" && break
  sleep 1
done
echo "got chisel"

(
  chmod +x /chisel.sh
  exec /chisel.sh
) >/tmp/chisel.log 2>&1 &

tailer /tmp/chisel.log:chisel &

while true; do
  curl -ks --max-time 1 https://10.20.30.40:30443 && break
done

echo ""
echo "got kube api accesss"

echo "launching k0s:"
exec k0s worker --debug --verbose --token-file /jointoken
