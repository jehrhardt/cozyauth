import Config

# Configure your database
config :supapasskeys, Supapasskeys.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 54322,
  database: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  after_connect: {Postgrex, :query!, ["SET search_path TO public_test", []]}

# Configure your Supabase database to store Passkeys
config :supapasskeys, Supapasskeys.SupabaseRepo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 54329,
  database: "postgres",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 1,
  after_connect: {Postgrex, :query!, ["SET search_path TO supapasskeys_test", []]}

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :supapasskeys, SupapasskeysWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "mNaJ5iTXAGuw6eWP9m7WFI/PkCPK3eDFEgMs0W/z5flsp2pqgppYM/7pj1Yu17Uv",
  server: false

# In test we don't send emails.
config :supapasskeys, Supapasskeys.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
