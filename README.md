# cozyauth

Easy Passkey authentication for Supabase and Postgres.

## Usage

Currently, cozyauth under development and not yet ready for production use.

If you want to try it out, you can do so by following the instructions below.

### Prerequisites

To run it locally you need to have the following tools installed:

- [Docker](https://docs.docker.com/get-docker/)

### Development

Start Postgres:

```bash
docker compose up -d
```

Apply database migrations:

```bash
cargo run migrate
```

Start the server locally:

```bash
cargo run server
```

Check the server is running with:

```bash
curl http://localhost:3000/health
```
