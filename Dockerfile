FROM rust:1.78.0-alpine3.19 AS rust-builder

WORKDIR /app

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

RUN cargo build --release --bin cozyauth-server

FROM ghcr.io/gleam-lang/gleam:v1.1.0-erlang-alpine AS gleam-builder

WORKDIR /app
COPY . .

RUN gleam export erlang-shipment

FROM alpine:3.19

WORKDIR /cozyauth
ENTRYPOINT ["/cozyauth/entrypoint.sh"]
CMD ["run"]

RUN apk add --no-cache \
  openssl \
  erlang

COPY --from=gleam-builder /app/build/erlang-shipment /cozyauth

USER nobody
