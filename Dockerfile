FROM rust:1.79.0-alpine3.20 AS builder

WORKDIR /app

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

RUN cargo build --release --bin cozyauth

FROM alpine:3.20

WORKDIR /cozyauth
ENTRYPOINT ["cozyauth"]

RUN apk add --no-cache \
  openssl

COPY --from=builder /app/target/release/cozyauth /usr/local/bin/cozyauth

USER nobody
