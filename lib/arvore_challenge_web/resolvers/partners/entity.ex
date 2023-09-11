defmodule ArvoreChallengeWeb.Resolvers.Partners.Entity do
  @moduledoc false

  alias Absinthe.Resolution
  alias ArvoreChallenge.Partners
  alias ArvoreChallenge.Partners.Entity

  @spec get_entity(map(), Resolution.t()) :: {:ok, map()} | {:error, atom()}
  def get_entity(%{id: entity_id}, _resolution) do
    case Partners.get_entity(entity_id) do
      {:error, reason} -> {:error, reason}
      {:ok, %Entity{} = entity} -> {:ok, build_response(entity)}
    end
  end

  @spec create_entity(map(), Resolution.t()) :: {:ok, map()} | {:error, map()}
  def create_entity(%{} = attrs, _resolution) do
    case Partners.create_entity(attrs) do
      {:error, reason} -> {:error, reason}
      {:ok, %Entity{} = entity} -> {:ok, build_response(entity)}
    end
  end

  @spec update_entity(map(), Resolution.t()) :: {:ok, map()} | {:error, map()}
  def update_entity(%{id: entity_id} = attrs, _resolution) do
    with {:ok, %Entity{} = entity} <- Partners.get_entity(entity_id),
         attrs_with_type <- Map.put(attrs, :entity_type, to_string(entity.entity_type)),
         {:ok, %Entity{} = updated_entity} <- Partners.update_entity(entity, attrs_with_type) do
      {:ok, build_response(updated_entity)}
    end
  end

  defp build_response(%Entity{} = entity) do
    %{
      id: entity.id,
      entity_type: to_string(entity.entity_type),
      inep: entity.inep,
      name: entity.name,
      parent_id: entity.parent_id,
      subtree_ids: Enum.map(entity.subtree, fn %{id: subtree_id} -> subtree_id end)
    }
  end
end
