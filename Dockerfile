FROM rust:1.77.2-alpine3.19 AS builder

WORKDIR /app

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

FROM builder AS server-builder

RUN cargo build --release --bin cozyauth-server

FROM builder AS cloud-builder

RUN cargo build --release --bin cozyauth-cloud

FROM alpine:3.19 AS release

WORKDIR /cozyauth
ENTRYPOINT ["cozyauth"]

RUN apk add --no-cache \
  openssl

FROM release AS server

COPY --from=server-builder /app/target/release/cozyauth-server /usr/local/bin/cozyauth

USER nobody

FROM release

COPY --from=cloud-builder /app/target/release/cozyauth-cloud /usr/local/bin/cozyauth

USER nobody
