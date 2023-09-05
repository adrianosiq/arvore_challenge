defmodule ArvoreChallenge.ReleaseTasks do
  @moduledoc false
  @app :arvore_challenge

  def migrate do
    load_app()

    for repo <- repos() do
      path = Ecto.Migrator.migrations_path(repo)
      run_migrations(repo, path)
    end
  end

  defp run_migrations(repo, path) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, path, :up, all: true))
  end

  defp repos, do: Application.fetch_env!(@app, :ecto_repos)
  defp load_app, do: Application.load(@app)
end
