FROM ubuntu:noble-20240429 AS api-builder

WORKDIR /app

# Get Ubuntu packages
RUN apt-get update -y \
    && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    curl \
    && apt-get clean \
    && rm -f /var/lib/apt/lists/*_*

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

COPY . .

RUN cargo build --release --bin cozyauth-api

FROM ubuntu:noble-20240429 AS api

WORKDIR /cozyauth
ENTRYPOINT ["cozyauth"]

COPY --from=api-builder /app/target/release/cozyauth-api /usr/local/bin/cozyauth

USER nobody

FROM hexpm/elixir:1.16.3-erlang-26.2.5-ubuntu-noble-20240429 AS app-builder

# install build dependencies
RUN apt-get update -y \
    && apt-get install -y \
    build-essential \
    git \
    && apt-get clean \
    && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force \
    && mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

FROM ubuntu:noble-20240429

CMD ["/app/bin/server"]

RUN apt-get update -y \
  && apt-get install -y \
  libstdc++6 \
  openssl \
  libncurses6 \
  locales ca-certificates \
  && apt-get clean \
  && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=app-builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/cozyauth ./

USER nobody
