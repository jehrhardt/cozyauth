FROM rust:1.79.0-alpine3.20 AS builder

WORKDIR /app

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

ARG BINARY=cozyauth-cloud
RUN cargo build --release --bin ${BINARY}

FROM alpine:3.20

WORKDIR /cozyauth
ENTRYPOINT ["cozyauth"]

RUN apk add --no-cache \
  openssl

ARG BINARY=cozyauth-cloud
COPY --from=builder /app/target/release/${BINARY} /usr/local/bin/cozyauth

USER nobody
