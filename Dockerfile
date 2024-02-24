FROM rust:1.76-bookworm AS builder

WORKDIR /supapasskeys

COPY . .

RUN cargo build --release

FROM debian:bookworm-20240211-slim AS release-base

CMD ["supapasskeys"]

WORKDIR /supapasskeys
RUN chown nobody /supapasskeys \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends \
  openssl=3.0.11-1~deb12u2 \
  && apt-get clean \
  && rm -f /var/lib/apt/lists/*_*

FROM release-base AS server

COPY --from=builder /supapasskeys/target/release/supapasskeys-server /usr/local/bin/supapasskeys

USER nobody

FROM release-base

COPY --from=builder /supapasskeys/target/release/supapasskeys-server-supabase /usr/local/bin/supapasskeys

USER nobody
