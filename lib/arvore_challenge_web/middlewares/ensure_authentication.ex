defmodule ArvoreChallengeWeb.Middlewares.EnsureAuthentication do
  @moduledoc false

  @behaviour Absinthe.Middleware

  import Absinthe.Resolution, only: [put_result: 2]

  def call(resolution, _) do
    case resolution.context do
      %{current_entity: _} -> resolution
      _ -> put_result(resolution, {:error, :unauthenticated})
    end
  end
end
