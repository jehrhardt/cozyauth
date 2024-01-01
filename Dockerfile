FROM node:21-bookworm AS builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

RUN npm run build

FROM denoland/deno:bin-1.39.1 AS deno

FROM ubuntu:jammy-20231211.1

# Create a non-privileged user
RUN useradd -m -s /bin/bash supapasskeys

# Set the working directory inside the container
WORKDIR /home/supapasskeys

ENV NODE_ENV=production
CMD deno run --unstable --allow-net --allow-read --allow-env /opt/supapasskeys/build/index.js

# Copy the Deno binary from the official image
COPY --from=deno /deno /usr/local/bin/deno

# Copy the binary from the builder stage to the final image
COPY --from=builder /app/build /opt/supapasskeys/build
COPY --from=builder /app/public /opt/supapasskeys/public

# Cache the dependencies
RUN deno cache /opt/supapasskeys/build/index.js

# Set the user to use when running this image
USER supapasskeys
