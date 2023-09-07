import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
database_name =
  "#{System.get_env("MYSQL_DATABASE", "arvore_challenge_test")}#{System.get_env("MIX_TEST_PARTITION")}"

config :arvore_challenge, ArvoreChallenge.Repo,
  username: System.get_env("MYSQL_USER", "root"),
  password: System.get_env("MYSQL_PASSWORD", "mysql"),
  hostname: System.get_env("MYSQL_HOST", "localhost"),
  database: database_name,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :arvore_challenge, ArvoreChallengeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "LbUMtLX78cWJWi9nM8/2d2LeNI1MpQ8bvZfZXT//tIH6j27S/5RJqJ7ymy85TwOo",
  server: false

# Print info, warnings, and errors during test
config :logger, level: :info

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
