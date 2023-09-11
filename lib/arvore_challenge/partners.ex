defmodule ArvoreChallenge.Partners do
  @moduledoc false

  alias ArvoreChallenge.Partners.Entity
  alias ArvoreChallenge.Repo

  @spec get_entity(Integer.t()) :: {:ok, Entity.t()} | {:error, :not_found}
  def get_entity(entity_id) when is_integer(entity_id) do
    case Repo.get(Entity, entity_id) do
      nil -> {:error, :not_found}
      %Entity{} = entity -> {:ok, Repo.preload(entity, [:parent, :subtree])}
    end
  end

  def get_entity(_entity_id), do: {:error, :bad_request}

  @spec create_entity(map()) :: {:ok, Entity.t()} | {:error, Ecto.Changeset.t()}
  def create_entity(_attrs)

  def create_entity(%{entity_type: "school"} = attrs) do
    required_fields = ~w(name entity_type inep)a
    optional_fields = ~w(parent_id)a

    %Entity{}
    |> Entity.changeset(attrs, required_fields, optional_fields)
    |> validate_parent_by_entity_type(:network)
    |> Repo.insert()
    |> handle_entity()
  end

  def create_entity(%{entity_type: "class"} = attrs) do
    required_fields = ~w(name entity_type parent_id)a

    %Entity{}
    |> Entity.changeset(attrs, required_fields)
    |> validate_parent_by_entity_type(:school)
    |> Repo.insert()
    |> handle_entity()
  end

  def create_entity(%{} = attrs),
    do: %Entity{} |> Entity.changeset(attrs) |> Repo.insert() |> handle_entity()

  @spec update_entity(Entity.t(), map()) :: {:ok, Entity.t()} | {:error, Ecto.Changeset.t()}
  def update_entity(_entity, _attrs)

  def update_entity(%Entity{} = entity, %{entity_type: "school"} = attrs) do
    required_fields = ~w(name entity_type inep)a
    optional_fields = ~w(parent_id)a

    entity
    |> Entity.changeset(attrs, required_fields, optional_fields)
    |> validate_parent_by_entity_type(:network)
    |> Repo.update()
    |> handle_entity()
  end

  def update_entity(%Entity{} = entity, %{entity_type: "class"} = attrs) do
    required_fields = ~w(name entity_type parent_id)a

    entity
    |> Entity.changeset(attrs, required_fields)
    |> validate_parent_by_entity_type(:school)
    |> Repo.update()
    |> handle_entity()
  end

  def update_entity(%Entity{} = entity, %{} = attrs),
    do: entity |> Entity.changeset(attrs) |> Repo.update() |> handle_entity()

  defp handle_entity({:ok, entity}), do: {:ok, Repo.preload(entity, [:parent, :subtree])}
  defp handle_entity({:error, changeset}), do: {:error, changeset}

  defp validate_parent_by_entity_type(%Ecto.Changeset{valid?: true} = changeset, entity_type) do
    Ecto.Changeset.validate_change(changeset, :parent_id, fn :parent_id, parent_id ->
      with true <- is_integer(parent_id),
           %Entity{entity_type: ^entity_type} <- Repo.get(Entity, parent_id) do
        []
      else
        false -> []
        nil -> [parent_id: "does not exist"]
        %Entity{} -> [parent_id: "is invalid, the entity type is not #{to_string(entity_type)}"]
      end
    end)
  end

  defp validate_parent_by_entity_type(%Ecto.Changeset{} = changeset, _entity_type), do: changeset
end
