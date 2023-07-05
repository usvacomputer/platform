#!/usr/bin/env bash

set -eEuo pipefail

if ! k0s
then
  curl -sSLf -o /tmp/k0s.sh https://get.k0s.sh
  chmod +x /tmp/k0s.sh
  sudo /tmp/k0s.sh
else
  echo "k0s already installed"
fi

sudo k0s install worker --token-file /tmp/usva/token
sudo k0s start
