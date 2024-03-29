defmodule ArvoreChallengeWeb.Router do
  use ArvoreChallengeWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(ArvoreChallengeWeb.Context)
  end

  scope "/api" do
    pipe_through(:api)

    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: ArvoreChallengeWeb.Schema,
      adapter: Absinthe.Adapter.LanguageConventions
    )

    forward("/", Absinthe.Plug,
      schema: ArvoreChallengeWeb.Schema,
      adapter: Absinthe.Adapter.LanguageConventions
    )
  end

  ## Health Check
  alias ArvoreChallenge.HealthChecker

  checkup_opts =
    PlugCheckup.Options.new(
      json_encoder: Jason,
      checks: [
        %PlugCheckup.Check{name: "DB", module: HealthChecker, function: :check_db}
      ]
    )

  forward("/health", PlugCheckup, checkup_opts)
end
