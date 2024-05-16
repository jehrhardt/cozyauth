FROM rust:1.78.0-alpine3.19 AS builder

WORKDIR /app

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

FROM builder AS server-builder

RUN cargo build --release --bin cozyauth-server

FROM builder AS ee-server-builder

RUN cargo build --release --bin cozyauth-ee-server

FROM alpine:3.19 AS release

WORKDIR /cozyauth
ENTRYPOINT ["cozyauth"]

RUN apk add --no-cache \
  openssl

FROM release AS server

COPY --from=server-builder /app/target/release/cozyauth-server /usr/local/bin/cozyauth

USER nobody

FROM release

COPY --from=ee-server-builder /app/target/release/cozyauth-ee-server /usr/local/bin/cozyauth

USER nobody
