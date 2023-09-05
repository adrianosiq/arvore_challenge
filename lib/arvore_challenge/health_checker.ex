defmodule ArvoreChallenge.HealthChecker do
  @moduledoc false

  def check_db do
    with {:ok, _} <- ArvoreChallenge.Repo.query("select 1", []), do: :ok
  end
end
