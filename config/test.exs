import Config

# Configure your database
config :supapasskeys, Supapasskeys.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "supapasskeys_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :supapasskeys, SupapasskeysWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "dASYiOAm+ZcTIyjoTDoLnaFWqdqcgpArcWG8nmjkd5Hx8ZE8G/A7CVDoeVy9KDht",
  server: false

# In test we don't send emails.
config :supapasskeys, Supapasskeys.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :supapasskeys, Supapasskeys.Passkeys,
  relying_party_name: "Supapasskeys",
  relying_party_origin: "http://localhost:4000"
