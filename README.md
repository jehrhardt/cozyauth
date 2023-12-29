# Supapasskeys
Easy Passkey authentication for Supabase.

This Supabase extension is currently under development. If you are interested, get in touch with us on [our Discord](https://discord.gg/QaCTXq2Gxm).

## Usage
Currently only usage during development is supported.

### Prerequisites
Supapasskeys requires a local Supabase instance to be running. You can start one using [Supabase CLI](https://supabase.com/docs/guides/cli):

```bash
supabase init
supabase start
```

### Installation

#### Create Supapasskeys schema and user
First, create a schema and DB user for Supapasskeys in your Supabase database. This can be done using migrations with the Supabase CLI:

```bash
supabase migration new create_supapasskeys_schema_and_user
```

Now add the following migration to the generated file:

```sql
CREATE SCHEMA supapasskeys;
CREATE ROLE supapasskeys WITH LOGIN PASSWORD '<your_supa_secret_password>';
GRANT USAGE, CREATE ON SCHEMA supapasskeys TO supapasskeys;
```

Make sure to replace `<your_supa_secret_password>` with a secure password.

#### Setup Supapasskeys API
Launch a Supapasskeys instance using [Docker Compose](https://docs.docker.com/compose/) by addind the following service to your `compose.yml` or (`docker-compose.yml`):

```yaml
services:
  supapasskeys:
    image: ghcr.io/jehrhardt/supapasskeys-api:latest
    ports:
      - 127.0.0.1:3000:3000
    environment:
      - SUPAPASSKEYS_DATABASE_URL=${SUPAPASSKEYS_DATABASE_URL}
      - SUPAPASSKEYS_RELYING_PARTY_NAME=${SUPAPASSKEYS_RELYING_PARTY_NAME}
      - SUPAPASSKEYS_RELYING_PARTY_ORIGIN=${SUPAPASSKEYS_RELYING_PARTY_ORIGIN}
    env_file:
      - .env
    networks:
      - supabase_network_<your_supabase_project_id>
```

Make sure to replace `<your_supabase_project_id>` with the ID of your Supabase project. You can find it in the generated `supabase/config.toml`.

You also need to reference the Supabase network in your `compose.yml` to access the allow Supapasskeys to access the Supabase services:

```yaml
networks:
  supabase_network_<your_supabase_project_id>:
    external: true
```

#### Configure Supapasskeys API
Now add a `.env` file to your project root with the following content:

```bash
SUPAPASSKEYS_DATABASE_URL=<your_supabase_database_url>
SUPAPASSKEYS_RELYING_PARTY_NAME=<your_relying_party_name>
SUPAPASSKEYS_RELYING_PARTY_ORIGIN=<your_relying_party_origin>
```

Make sure to replace `<your_supabase_database_url>` with the URL of your Supabase database. Usually it will look like this: `postgres://supapasskeys:<your_supa_secret_password>@supabase_db_<your_supabase_project_id>:5432/postgres`, where `<your_supa_secret_password>` is the password you set in the migration and `<your_supabase_project_id>` is the ID of your Supabase project (see above). The port is usually `5432` and not the public Supabase port `54322`.

Also replace `<your_relying_party_name>` with the name of your relying party (e.g. your app name) and `<your_relying_party_origin>` with the origin of your relying party (e.g. `http://localhost:3000`).

## Development
Supapasskeys requires the following tools to be installed on your system:

- [Docker](https://docs.docker.com/get-docker/)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Rust](https://www.rust-lang.org/tools/install)

Start the local Supabase instance:

```bash
supabase start
```

Start the Supapasskeys API:

```bash
cargo run
```
