# cozyauth

Easy Passkey authentication for Supabase and Postgres.

## Usage

Currently, cozyauth under development and not yet ready for production use.

If you want to try it out, you can do so by following the instructions below.

### Prerequisites

To run it locally you need to have the following tools installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Elixir](https://elixir-lang.org/install.html)

### Development

Start Postgres:

```bash
docker compose up -d db
```

Apply database migrations:

```bash
mix setup
```

Start the server locally:

```bash
mix phx.server
```

Check the server is running with:

```bash
curl http://localhost:4000/health
```
