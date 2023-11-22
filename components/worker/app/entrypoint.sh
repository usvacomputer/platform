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

export KUBECONFIG=$HOME/.kube/config
mkdir -p "$KUBECONFIG"

ifconfig lo:20 10.20.30.40 netmask 255.255.255.0 up

while true; do
  curl -Lsf --max-time 60 -o "$KUBECONFIG" "https://${USVA_ENV}-beacon.${USVA_DOMAIN}/v1/cluster/${USVA_NAME}/kubeconfig" && break
  echo "can not get kubeconfig, retrying..."
  sleep 1
done
echo "got cluster"

until kubectl apply -f https://raw.githubusercontent.com/matti/k8s-unreachable-node-cleaner/main/k8s/all.yml ; do
  echo "can not apply k8s-unreachable-node-cleaner, retrying..."
  sleep 1
done

while true; do
  curl -Lsf --max-time 60 -o /dev/null "https://${USVA_ENV}-beacon.${USVA_DOMAIN}/v1/cluster/${USVA_NAME}/magico" && break
  echo "can not get magico retrying..."
  sleep 1
done
echo "got magico"

while true; do
  curl -Lsf --max-time 30 -o /jointoken "https://${USVA_ENV}-beacon.${USVA_DOMAIN}/v1/cluster/${USVA_NAME}/jointoken" && break
  echo "can not get jointoken retrying..."
  sleep 1
done
echo "got jointoken"

while true; do
  curl -Lsf --max-time 10 -o /chisel.sh "https://${USVA_ENV}-beacon.${USVA_DOMAIN}/v1/cluster/${USVA_NAME}/chisel.sh" && break
  echo "can not get chisel retrying..."
  sleep 1
done
echo "got chisel"

(
  chmod +x /chisel.sh
  exec /chisel.sh
) >/tmp/chisel.log 2>&1 &

tailer /tmp/chisel.log:chisel &

until curl -ks --max-time 1 https://10.20.30.40:30443 ; do
  echo "can not get kube api, retrying..."
  sleep 1
done

echo ""
echo "got kube api accesss"

echo "launching k0s:"
exec k0s worker --debug --verbose --token-file /jointoken
