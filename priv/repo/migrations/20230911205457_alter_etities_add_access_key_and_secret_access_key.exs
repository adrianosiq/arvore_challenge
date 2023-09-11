defmodule ArvoreChallenge.Repo.Migrations.AlterEtitiesAddAccessKeyAndSecretAccessKey do
  use Ecto.Migration

  def change do
    alter table(:entities) do
      add(:access_key, :text, null: false)
      add(:secret_access_key, :text, null: false)
    end
  end
end
