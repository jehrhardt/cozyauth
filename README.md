# Supapasskeys
Easy Passkey authentication for Supabase.

This extension is currently under development. If you are interested, get in touch with us on [our Discord](https://discord.gg/QaCTXq2Gxm).

## Prerequisites

  * [Docker](https://docs.docker.com/get-docker/)
  * [Supabase CLI](https://supabase.io/docs/guides/cli)
  * [Elixir](https://elixir-lang.org/install.html)
  * [Rust](https://www.rust-lang.org/tools/install)

## Usage
To start local server:

  * Launch DB with `docker-compose up -d`
  * Launch Supabase with `supabase start`
  * Run `mix setup` to install and setup dependencies
  * Start Supapasskeys with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
