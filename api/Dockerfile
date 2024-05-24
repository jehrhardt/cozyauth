FROM rust:1.78.0-alpine3.19 AS builder

WORKDIR /app

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

RUN cargo build --release --bin cozyauth-api

FROM alpine:3.20

WORKDIR /cozyauth
ENTRYPOINT ["cozyauth"]

RUN apk add --no-cache \
  openssl

COPY --from=builder /app/target/release/cozyauth-api /usr/local/bin/cozyauth

USER nobody
