#!/usr/bin/env bash

set -eEuo pipefail

until apt-get update
do
  sleep 1
done

until apt-get install -y --no-install-recommends screen
do
  sleep 1
done

screen -dmS async /tmp/usva/mcp/bootstrap/async.sh

cp /tmp/usva/mcp/bootstrap/k0s /usr/local/bin

k0s install controller --single
systemctl daemon-reload
k0s start

until [[ -f /var/lib/k0s/pki/admin.conf ]] ; do
  echo "waiting for /var/lib/k0s/pki/admin.conf"
  sleep 1
done

cp /var/lib/k0s/pki/admin.conf /tmp/usva/mcp/kubeconfig

echo "KUBECONFIG in /tmp/usva/kubeconfig"

wait
