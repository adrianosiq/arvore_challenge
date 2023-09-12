# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :arvore_challenge,
  ecto_repos: [ArvoreChallenge.Repo]

# Configures the endpoint
config :arvore_challenge, ArvoreChallengeWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: ArvoreChallengeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ArvoreChallenge.PubSub,
  live_view: [signing_salt: "8ONeek1i"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Guardian's authentication
config :arvore_challenge, ArvoreChallenge.Authorizations.Guardian,
  issuer: "arvore_challenge",
  secret_key: System.get_env("GUARDIAN_TOKEN"),
  ttl: {1, :day}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
