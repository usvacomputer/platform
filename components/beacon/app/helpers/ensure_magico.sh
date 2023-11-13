#!/usr/bin/env bash
set -eEuo pipefail
source /app/helpers/functions.sh

CLUSTER_NAME=$1
PORT=$2

tunnel_name="${USVA_ENV}-k-${CLUSTER_NAME}"
tunnel_secret="${USVA_ENV}-k-${CLUSTER_NAME}-secret-schmecrets-lollers-catters-bomb"

tunnel_json=$(
  /app/helpers/ensure_tunnel.sh "$tunnel_name" "$tunnel_secret"
)

tunnel_id=$(
  echo "$tunnel_json" | jq -r '.TunnelID'
)
tunnel_secret_base64=$(
  echo "$tunnel_json" | jq -r '.TunnelSecret'
)

echo """
apiVersion: v1
kind: Service
metadata:
  name: kmc-${CLUSTER_NAME}
spec:
  selector:
    app: k0smotron
    cluster: ${CLUSTER_NAME}
  ports:
    - protocol: TCP
      port: 6443
      targetPort: ${PORT}
""" | 1>&2 kubectl apply -f -

echo """
apiVersion: apps/v1
kind: Deployment
metadata:
  name: magico-${CLUSTER_NAME}
  labels:
    app: magico
    cluster: ${CLUSTER_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: magico
      cluster: ${CLUSTER_NAME}
  template:
    metadata:
      labels:
        app: magico
        cluster: ${CLUSTER_NAME}
    spec:
      containers:
        - name: magico
          image: mattipaksula/magico:5
          env:
            - name: CLOUDFLARE_ACCOUNT_TAG
              value: ${CLOUDFLARE_ACCOUNT_TAG}
            - name: CLOUDFLARE_TUNNEL_SECRET
              value: ${tunnel_secret_base64}
            - name: CLOUDFLARE_TUNNEL_ID
              value: ${tunnel_id}
""" | 1>&2 kubectl apply -f -

echo "$tunnel_json"
