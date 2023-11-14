# usva

```console
export KUBECONFIG=/tmp/usva/kubeconfig
kubectl create secret generic beacon-cloudflare-pem --from-file=cloudflare/cert.pem
skaffold dev
```

```console
chisel client --auth magico:sekret https://test-1.usva.io 6443:kmc-test-1:30443
```

curl -k <https://matti-1-beacon.usva.io/v1/cluster/a/kubeconfig>

```
docker run --rm --privileged -v /var/lib/k0s --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw -e USVA_DOMAIN=usva.io -e USVA_ENV=matti-1 -e USVA_NAME=pkilo mattipaksula/worker:1
```
