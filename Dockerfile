FROM node:20-bookworm AS builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

RUN npm run build

FROM denoland/deno:bin-1.39.2 AS deno

FROM ubuntu:jammy-20231211.1

# Set the working directory inside the container
WORKDIR /app
RUN chown nobody /app
ENV DENO_DIR =/app

ENV NODE_ENV=production
CMD deno run --unstable --allow-net --allow-read --allow-env /opt/supapasskeys/build/index.js

# Copy the Deno binary from the official image
COPY --from=deno /deno /usr/local/bin/deno

# Copy the binary from the builder stage to the final image
COPY --from=builder /app/build /opt/supapasskeys/build
COPY --from=builder /app/public /opt/supapasskeys/public

# Set the user to use when running this image
USER nobody

# Cache the dependencies
RUN deno cache /opt/supapasskeys/build/index.js
