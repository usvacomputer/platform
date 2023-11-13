FROM ubuntu:22.04 as installer
ARG TARGETARCH

RUN set -eux ; \
  apt-get update ; \
  apt-get install -y --no-install-recommends \
  ca-certificates curl

FROM installer as reflex
RUN set -eux ; \
  mkdir /ghjk ; cd /ghjk ; \
  curl -Lf -o reflex.tar.gz "https://github.com/cespare/reflex/releases/download/v0.3.1/reflex_linux_${TARGETARCH}.tar.gz" ; \
  tar -xvof reflex.tar.gz ; \
  mv reflex_linux_arm64/reflex /reflex ; \
  rm -rf /ghjk

FROM installer as kubectl
RUN set -eux ; \
  curl -LfO "https://dl.k8s.io/release/v1.28.3/bin/linux/${TARGETARCH}/kubectl" ; \
  chmod +x ./kubectl

FROM installer as cloudflared
RUN set -eux ; \
  curl -Lfso "/cloudflared" "https://github.com/cloudflare/cloudflared/releases/download/2023.10.0/cloudflared-linux-${TARGETARCH}" ; \
  chmod +x /cloudflared

FROM installer as jq
RUN set -eux ; \
  curl -Lsf -o /jq "https://github.com/stedolan/jq/releases/download/jq-1.7/jq-linux-${TARGETARCH}" ; \
  chmod +x /jq


FROM ruby:3.2.2-slim-bookworm
RUN set -eux ; \
  apt-get update ; \
  apt-get install -y --no-install-recommends \
  ca-certificates

COPY --from=reflex /reflex /usr/local/bin
COPY --from=kubectl /kubectl /usr/local/bin
COPY --from=cloudflared /cloudflared /usr/local/bin
COPY --from=jq /jq /usr/local/bin
COPY --from=ghcr.io/matti/tailer:824002811ee20a0dbb19501e77553b49ebdf5869 /tailer /usr/local/bin

WORKDIR /app

COPY app/Gemfile .
RUN bundle install

COPY app .

RUN mkdir /root/.cloudflared
ENTRYPOINT [ "/app/entrypoint.sh" ]
