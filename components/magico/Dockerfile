FROM ubuntu:22.04 as installer
ARG TARGETARCH

RUN set -eux ; \
  apt-get update ; \
  apt-get install -y --no-install-recommends ca-certificates curl

FROM installer as cloudflared
RUN set -eux ; \
  curl -Lfso "/cloudflared" "https://github.com/cloudflare/cloudflared/releases/download/2023.10.0/cloudflared-linux-${TARGETARCH}" ; \
  chmod +x /cloudflared

FROM installer as chisel
RUN set -eux ; \
  curl -Lfso "/chisel.gz" "https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_${TARGETARCH}.gz" ; \
  gzip -d /chisel.gz ; \
  chmod +x /chisel

FROM installer as envsubst
RUN set -eux ; \
  curl -Lfso "/envsubst" "https://github.com/a8m/envsubst/releases/download/v1.4.2/envsubst-Linux-${TARGETARCH}" ; \
  chmod +x /envsubst

FROM ubuntu:22.04
RUN set -eux ; \
  apt-get update ; \
  apt-get install -y --no-install-recommends ca-certificates curl

COPY --from=cloudflared /cloudflared /usr/local/bin
COPY --from=chisel /chisel /usr/local/bin
COPY --from=envsubst /envsubst /usr/local/bin
COPY --from=ghcr.io/matti/tailer:824002811ee20a0dbb19501e77553b49ebdf5869 /tailer /usr/local/bin

WORKDIR /app
COPY app .
ENTRYPOINT [ "/app/entrypoint.sh" ]
