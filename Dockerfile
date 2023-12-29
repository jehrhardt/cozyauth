# Use the official Rust image as the base image
FROM rust:latest AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the source code to the container
COPY Cargo.toml Cargo.lock ./
COPY migration ./migration
COPY src ./src

# Build the application
RUN cargo build --release

FROM ubuntu:jammy-20231211.1

# Create a non-privileged user
RUN useradd -m -s /bin/bash supapasskeys

# Set the working directory inside the container
WORKDIR /home/supapasskeys

CMD [ "supapasskeys" ]

# Copy the binary from the builder stage to the final image
COPY --from=builder /app/target/release/main /usr/local/bin/supapasskeys

# Set the user to use when running this image
USER supapasskeys
