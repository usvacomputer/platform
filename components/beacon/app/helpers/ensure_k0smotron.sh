#!/usr/bin/env bash
set -eEuo pipefail
source /app/helpers/functions.sh

CLUSTER_NAME=$1


echo """
apiVersion: k0smotron.io/v1beta1
kind: Cluster
metadata:
  name: ${CLUSTER_NAME}
spec:
  externalAddress: 10.20.30.40
  service:
    type: LoadBalancer
""" | 1>&2 kubectl apply -f -

while true; do
  status=$(
    kubectl get cluster "$CLUSTER_NAME" -o jsonpath='{.status.reconciliationStatus}' || true
  )
  if [[ "$status" == "Reconciliation successful" ]] ; then
    break
  fi

  _echoerr "status.reconciliationStatus: $status"

  sleep 1
done

kubectl get secret "${CLUSTER_NAME}-kubeconfig" -o jsonpath='{.data.value}' | base64 -d
