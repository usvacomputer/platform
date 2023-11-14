FROM ubuntu:22.04 as installer
ARG TARGETARCH

RUN set -eux ; \
  apt-get update ; \
  apt-get install --no-install-recommends -y \
  ca-certificates curl

FROM installer as k0s

RUN set -eux ; \
  curl -Lf -o k0s "https://github.com/k0sproject/k0s/releases/download/v1.27.2%2Bk0s.0/k0s-v1.27.2+k0s.0-${TARGETARCH}" ; \
  chmod +x ./k0s

FROM installer as chisel

RUN set -eux ; \
  curl -Lfso "/chisel.gz" "https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_${TARGETARCH}.gz" ; \
  gzip -d /chisel.gz ; \
  chmod +x /chisel

# FROM ubuntu:22.04

# RUN set -eux ; \
#   apt-get update ; \
#   apt-get install --no-install-recommends -y \
#   ca-certificates curl

# COPY --from=k0s /k0s /usr/local/bin/k0s
# COPY --from=chisel /chisel /usr/local/bin/chisel
# COPY --from=ghcr.io/matti/tailer:824002811ee20a0dbb19501e77553b49ebdf5869 /tailer /usr/local/bin

# WORKDIR /app
# COPY app .
# ENTRYPOINT [ "/app/entrypoint.sh" ]

FROM docker.io/k0sproject/k0s:v1.27.2-k0s.0

COPY --from=chisel /chisel /usr/local/bin/chisel
COPY --from=ghcr.io/matti/tailer:824002811ee20a0dbb19501e77553b49ebdf5869 /tailer /usr/local/bin

WORKDIR /app
COPY app .
ENTRYPOINT [ "/app/entrypoint.sh" ]
