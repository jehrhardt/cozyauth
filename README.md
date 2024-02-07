# Supapasskeys

Easy Passkey authentication for Supabase.

This Supabase extension is currently under development. If you are interested,
get in touch with us on [our Discord](https://discord.gg/QaCTXq2Gxm).

## Usage

Currently only usage during development is supported.

### Prerequisites

Supapasskeys requires a local Supabase instance to be running. You can start one
using [Supabase CLI](https://supabase.com/docs/guides/cli):

```bash
supabase init
supabase start
```

### Installation

#### Adjust Supabase config

Activate DB pooler in your `supabase/config.toml`:

```toml
[db.pooler]
enabled = true
```

The config can be enabled by restarting your Supabase instance:

```bash
supabase stop
supabase start
```

#### Create Supapasskeys schema and user

First, create a schema and DB user for Supapasskeys in your Supabase database.
This can be done using migrations with the Supabase CLI:

```bash
supabase migration new create_supapasskeys_schema_and_user
```

Now add the following migration to the generated file:

```sql
create schema supapasskeys;
create role "supapasskeys" with login password 'supapasskeys';
grant create, usage on schema supapasskeys to supapasskeys;
```

Now reset your database to apply the migration:

```bash
supabase db reset
```

#### Setup Supapasskeys API

Launch a Supapasskeys instance using
[Docker Compose](https://docs.docker.com/compose/) by addind the following
service to your `compose.yml` or (`docker-compose.yml`):

```yaml
version: '3.8'
services:
  supapasskeys:
    image: ghcr.io/jehrhardt/supapasskeys:main
    ports:
      - 127.0.0.1:4000:4000
    env_file:
      - .env
    networks:
      - supabase_network_<your_supabase_project_id>
```

Make sure to replace `<your_supabase_project_id>` with the ID of your Supabase
project. You can find it in the generated `supabase/config.toml`.

You also need to reference the Supabase network in your `compose.yml` to access
the allow Supapasskeys to access the Supabase services:

```yaml
networks:
  supabase_network_<your_supabase_project_id>:
    external: true
```

#### Configure Supapasskeys API

Now add a `.env` file to your project root with the following content:

```bash
DATABASE_URL=<your_supabase_database_url>
SECRET_KEY_BASE=<your_supa_secret_key>
SUPAPASSKEYS_RELYING_PARTY_NAME=<your_relying_party_name>
SUPAPASSKEYS_RELYING_PARTY_ORIGIN=<your_relying_party_origin>
```

Make sure to replace `<your_supabase_database_url>` with the URL of your
Supabase database. Usually it will look like this:
`ecto://postgres:postgres@supabase_db_<your_supabase_project_id>/postgres`,
where `<your_supa_secret_password>` is the password you set in the migration and
`<your_supabase_project_id>` is the ID of your Supabase project (see above). The
port is usually `5432` and not the public Supabase port `54322`.

Make sure to replace `<your_supa_secret_key>` with a secure secret key. You can generate one using the following command:

```bash
openssl rand -hex 32
```

Also replace `<your_relying_party_name>` with the name of your relying party
(e.g. your app name) and `<your_relying_party_origin>` with the origin of your
relying party (e.g. `http://localhost:3000`).

## Development

### Prerequisites

Supapasskeys requires the following tools to be installed on your system:

- [Docker](https://docs.docker.com/get-docker/)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Elixir](https://elixir-lang.org/install.html)
- [Rust](https://www.rust-lang.org/tools/install)
- [Node.js](https://nodejs.org/en/download/)
- [deno](https://deno.land/manual/getting_started/installation)

### Setup

Start the local Supabase instance:

```bash
supabase start
```

Install dependencies:

```bash
npm install
```

### Launch application

Start Supapasskeys:

```bash
npm run dev
```

You can now open the application in your browser at http://localhost:8000.

### Launch API
Setup development environment:

```bash
mix setup
```

Then start the Supapasskeys API:

```bash
mix phx.server
```

You can now access the API at http://localhost:3000.
