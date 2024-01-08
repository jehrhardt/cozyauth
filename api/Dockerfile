FROM hexpm/elixir:1.16.0-erlang-26.2.1-ubuntu-jammy-20231004 as builder

# install build dependencies
RUN apt-get update -y \
  && apt-get install -y \
  build-essential \
  git \
  curl \
  libssl-dev \
  pkg-config

# install Rust for native dependencies
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

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

# Compile the release
COPY priv priv
COPY native native
COPY lib lib

RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

FROM ubuntu:jammy-20231211.1

RUN apt-get update -y \
  && apt-get install -y \
  libstdc++6 \
  openssl \
  libncurses5 \
  locales \
  && apt-get clean \
  && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set the working directory inside the container
WORKDIR /app
RUN chown nobody /app

ENV MIX_ENV="prod"
CMD /opt/supapasskeys/bin/server

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/supapasskeys /opt/supapasskeys

# Set the user to use when running this image
USER nobody
