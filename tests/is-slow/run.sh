#!/usr/bin/env bash
set -eEuo pipefail

kubectl apply -f slow.yml

while true
do
  >/dev/null 2>&1 kubectl get pod kmc-slow-1-0 && break
  sleep 1
done

echo "pod took: ${SECONDS}s"

(
  while true
  do
    >/dev/null 2>&1 kubectl get secret slow-1-kubeconfig && break
    sleep 1
  done

  echo "kubeconfig took: ${SECONDS}s"
) &

(
  while true
  do
    >/dev/null 2>&1 kubectl get secret slow-1 && break
    sleep 1
  done
  echo "join token took: ${SECONDS}s"
) &

wait

kubectl delete cluster slow-1
kubectl delete jointokenrequest slow-1
