defmodule ArvoreChallenge.Partners.Entity do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias ArvoreChallenge.Partners.Entity

  @type t :: %__MODULE__{
          id: nil | Integer.t(),
          entity_type: nil | String.t(),
          inep: nil | Integer.t(),
          name: nil | String.t(),
          parent_id: nil | Integer.t(),
          parent: nil | Entity.t() | Ecto.Association.NotLoaded.t(),
          access_key: nil | String.t(),
          secret_access_key: nil | String.t()
        }

  @timestamps_opts [type: :naive_datetime_usec]
  schema "entities" do
    field(:entity_type, Ecto.Enum, values: [:network, :school, :class])
    field(:inep, :integer)
    field(:name, :string)
    field(:access_key, :string)
    field(:secret_access_key, :string)
    belongs_to(:parent, __MODULE__, foreign_key: :parent_id)
    has_many(:subtree, __MODULE__, foreign_key: :parent_id)

    timestamps()
  end

  @spec changeset(t(), map(), Keyword.t(), Keyword.t()) :: Ecto.Changeset.t()
  def changeset(
        %__MODULE__{} = entity,
        %{} = attrs,
        required_fields \\ ~w(name entity_type)a,
        optional_fields \\ ~w()a
      ) do
    entity
    |> cast(attrs, required_fields ++ optional_fields)
    |> validate_required(required_fields)
    |> validate_inclusion(:entity_type, [:network, :school, :class])
  end
end
