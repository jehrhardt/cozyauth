FROM rust:1.79.0-alpine3.20 AS builder

WORKDIR /app

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

RUN RUSTFLAGS="-C target-feature=-crt-static" cargo build --release --bin cozyauth

FROM alpine:3.20

WORKDIR /cozyauth
ENTRYPOINT ["cozyauth"]
CMD [ "server" ]

RUN apk add --no-cache \
  libgcc \
  openssl

COPY --from=builder /app/target/release/cozyauth /usr/local/bin/cozyauth

USER nobody
