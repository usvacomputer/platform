#!/usr/bin/env bash
set -eEuo pipefail
source /app/helpers/functions.sh

CLUSTER_NAME=$1

echo """
apiVersion: k0smotron.io/v1beta1
kind: JoinTokenRequest
metadata:
  name: ${CLUSTER_NAME}
spec:
  clusterRef:
    name: ${CLUSTER_NAME}
    namespace: default
""" | 1>&2 kubectl apply -f -

while true; do
  status=$(
    kubectl get jointokenrequest "$CLUSTER_NAME" -o jsonpath='{.status.reconciliationStatus}' || true
  )
  if [[ "$status" == "Reconciliation successful" ]] ; then
    break
  fi

  _echoerr "status.reconciliationStatus: $status"

  sleep 1
done

kubectl get secret "${CLUSTER_NAME}" -o jsonpath='{.data.token}' | base64 -d
