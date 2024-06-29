FROM rust:1.79.0-alpine3.20 AS nif-builder

WORKDIR /app

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

RUN cargo build

FROM ghcr.io/gleam-lang/gleam:v1.2.1-erlang-alpine AS builder

WORKDIR /app

COPY . .

RUN gleam export erlang-shipment

FROM hexpm/erlang:27.0-alpine-3.20.1

WORKDIR /cozyauth
ENTRYPOINT ["/usr/local/cozyauth/entrypoint.sh"]
CMD [ "run" ]

COPY --from=builder /app/build/erlang-shipment /usr/local/cozyauth

USER nobody
