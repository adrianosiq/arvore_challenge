defmodule ArvoreChallengeWeb.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias ArvoreChallengeWeb.Middlewares.ErrorHandler
  alias ArvoreChallengeWeb.Resolvers.Partners.Entity

  query do
    field :entity, :entity do
      arg(:id, non_null(:integer))

      resolve(&Entity.get_entity/2)
    end
  end

  mutation do
    field :create_entity, :entity do
      arg(:name, non_null(:string))
      arg(:entity_type, non_null(:string))
      arg(:parent_id, :integer)
      arg(:inep, :string)

      resolve(&Entity.create_entity/2)
    end

    field :update_entity, :entity do
      arg(:id, non_null(:integer))
      arg(:name, non_null(:string))
      arg(:parent_id, :integer)
      arg(:inep, :string)

      resolve(&Entity.update_entity/2)
    end
  end

  object :entity do
    field(:id, :integer)
    field(:entity_type, :string)
    field(:inep, :integer)
    field(:name, :string)
    field(:parent_id, :integer)
    field(:subtree_ids, list_of(:integer))
  end

  # coveralls-ignore-start
  def middleware(middleware, _field, %{identifier: type}) when type in [:query, :mutation] do
    middleware ++ [ErrorHandler]
  end

  def middleware(middleware, _field, _object), do: middleware
  # coveralls-ignore-stop
end
