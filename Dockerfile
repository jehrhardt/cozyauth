FROM rust:1.77.2-alpine3.19 as builder

WORKDIR /app

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

RUN cargo build --release --bin cozyauth-server

FROM alpine:3.19

WORKDIR /cozyauth
ENTRYPOINT ["cozyauth"]

RUN apk add --no-cache \
  openssl

COPY --from=builder /app/target/release/cozyauth-server /usr/local/bin/cozyauth

USER nobody
