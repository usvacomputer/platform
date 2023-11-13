#!/usr/bin/env bash
set -eEuo pipefail
source /app/helpers/functions.sh

name=$1

magico_name="magico-${name}"
while true; do
  >/dev/null 2>&1 kubectl get deployment "$magico_name" || break
  kubectl delete deployment "$magico_name" || true
done

while true; do
  >/dev/null 2>&1 kubectl get cluster "$name" || break
  kubectl delete cluster "$name" || true
done

service_name="kmc-${name}"
while true; do
  >/dev/null 2>&1 kubectl get service "$service_name" || break
  kubectl delete service "$service_name" || true
done
