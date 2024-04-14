FROM rust:1.77.2-alpine3.19 as builder

WORKDIR /app

ARG RUSTFLAGS="-C target-feature=-crt-static"

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

RUN cargo build --release

FROM alpine:3.19

WORKDIR /app
ENTRYPOINT ["cozyauth"]
ENV APP_PROFILE=prod

RUN apk add --no-cache \
  openssl \
  libgcc

COPY --from=builder /app/target/release/server /usr/local/bin/cozyauth
COPY --from=builder /app/server/configuration server/configuration

USER nobody
