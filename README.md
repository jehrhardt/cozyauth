# Supapasskeys
Easy Passkey authentication for Supabase.

This extension is currently under development. If you are interested, get in touch with us on [our Discord](https://discord.gg/QaCTXq2Gxm).

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Rust](https://www.rust-lang.org/tools/install)
- [sqlx CLI](https://github.com/launchbadge/sqlx/tree/main/sqlx-cli#install)

## Usage
To start local server:

 - Launch DB with `docker-compose up -d`
 - Apply migrations with `sqlx migrate run --database-url postgres://postgres:postgres@localhost/supapasskeys`
 - Start Supapasskeys with `cargo run`

Now you can start a Passkey registration via `curl`:

```bash
curl -X POST -i -H "Content-Type: application/json" -d '{"id": "2bd11802-1fe3-4260-b741-482082226348", "name": "jan.ehrhardt@gmail.com", "display_name": "Jan"}' http://localhost:3000/
```
