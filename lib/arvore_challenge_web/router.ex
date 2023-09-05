defmodule ArvoreChallengeWeb.Router do
  use ArvoreChallengeWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", ArvoreChallengeWeb do
    pipe_through(:api)
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
