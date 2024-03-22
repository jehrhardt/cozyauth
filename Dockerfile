FROM rust:1.77.0-alpine3.18 as builder

WORKDIR /app

COPY . .

RUN cargo build --release

FROM alpine:3.19

ENTRYPOINT ["/cozyauth"]

COPY --from=builder /app/target/release/cozyauth /cozyauth
