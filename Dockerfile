FROM rust:1.77.0-alpine3.19 AS builder

WORKDIR /app

ARG RUSTFLAGS="-C target-feature=-crt-static"
ARG EXECUTABLE=cozyauth-server

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

RUN cargo build --bin ${EXECUTABLE} --release

FROM alpine:3.19 AS release

ENTRYPOINT ["/cozyauth"]

RUN apk add --no-cache \
  openssl \
  libgcc

FROM release AS server

COPY --from=builder /app/target/release/cozyauth-server /cozyauth

USER nobody

FROM release

COPY --from=builder /app/target/release/cozyauth-multi-tenant /cozyauth

USER nobody
