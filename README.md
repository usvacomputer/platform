# usva

```console
export KUBECONFIG=/tmp/usva/kubeconfig
kubectl create secret generic beacon-cloudflare-pem --from-file=cloudflare/cert.pem
skaffold dev
```

```console
chisel client --auth magico:sekret https://test-1.usva.io 6443:kmc-test-1:30443
```
