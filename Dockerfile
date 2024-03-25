FROM rust:1.77.0-alpine3.19 as builder

WORKDIR /app

ARG RUSTFLAGS="-C target-feature=-crt-static"
ARG EXECUTABLE=cozyauth-server

RUN apk add --no-cache \
  musl-dev \
  openssl-dev

COPY . .

RUN cargo build --bin ${EXECUTABLE} --release

FROM alpine:3.19

ENTRYPOINT ["/cozyauth"]

ARG EXECUTABLE=cozyauth-server

RUN apk add --no-cache \
  openssl \
  libgcc

COPY --from=builder /app/target/release/${EXECUTABLE} /cozyauth

USER nobody
