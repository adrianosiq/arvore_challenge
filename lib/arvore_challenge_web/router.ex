defmodule ArvoreChallengeWeb.Router do
  use ArvoreChallengeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ArvoreChallengeWeb do
    pipe_through :api
  end
end
