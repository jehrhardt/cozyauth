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

 - Launch DB with `docker-compose up -d`
 - Apply migrations with `DATABASE_URL=postgres://postgres:postgres@localhost/supapasskeys cargo run -- up` in `migration` directory
 - Start Supapasskeys with `cargo run`

Now you can start a Passkey registration via `curl`:

```bash
curl -X POST -i -H "Content-Type: application/json" -d '{"id": "2bd11802-1fe3-4260-b741-482082226348", "name": "jan.ehrhardt@gmail.com", "display_name": "Jan"}' http://localhost:3000/
```
