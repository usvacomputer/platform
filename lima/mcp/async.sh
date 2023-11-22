#!/usr/bin/env bash

set -eEuo pipefail

(
  until apt-get update ; do
    sleep 1
  done

  until apt-get install -y --no-install-recommends \
    curl wget iputils-ping ; do
    sleep 1
  done

  echo "done"
) 2>&1 | sed -le "s#^#installer: #;" &

images="""
  docker.io/k0sproject/k0s:v1.28.3-k0s.0
  docker.io/mattipaksula/magico:5
"""

for image in $images ; do
  (
    until k0s ctr images pull "$image"
    do
      sleep 1
    done

    echo "done"
  ) 2>&1 | sed -le "s#^#pull $image: #;" &
done

wait
