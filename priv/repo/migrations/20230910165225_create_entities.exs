defmodule ArvoreChallenge.Repo.Migrations.CreateEntities do
  use Ecto.Migration

  def change do
    create table(:entities) do
      add(:name, :string, null: false)
      add(:entity_type, :string, null: false)
      add(:inep, :integer, null: true)
      add(:parent_id, references(:entities), null: true)

      timestamps(type: :naive_datetime_usec)
    end

    create(unique_index(:entities, [:inep]))
  end
end
