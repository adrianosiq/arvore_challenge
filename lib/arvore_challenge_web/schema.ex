defmodule ArvoreChallengeWeb.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias ArvoreChallengeWeb.Middlewares.EnsureAuthentication
  alias ArvoreChallengeWeb.Middlewares.ErrorHandler
  alias ArvoreChallengeWeb.Resolvers.Authorizations.Authorization
  alias ArvoreChallengeWeb.Resolvers.Partners.Entity

  query do
    field :entity, :entity do
      arg(:id, non_null(:integer))

      middleware(EnsureAuthentication)
      resolve(&Entity.get_entity/2)
    end
  end

  mutation do
    field :create_entity, :entity_with_credentials do
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

      middleware(EnsureAuthentication)
      resolve(&Entity.update_entity/2)
    end

    field :autorization, :autorization do
      arg(:access_key, non_null(:string))
      arg(:secret_access_key, non_null(:string))

      resolve(&Authorization.auhorization/2)
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

  object :entity_with_credentials do
    import_fields(:entity)
    field(:access_key, :string)
    field(:secret_access_key, :string)
  end

  object :autorization do
    field(:access_token, :string)
    field(:expires_in, :integer)
    field(:token_type, :string)
  end

  # coveralls-ignore-start
  def middleware(middleware, _field, %{identifier: type}) when type in [:query, :mutation] do
    middleware ++ [ErrorHandler]
  end

  def middleware(middleware, _field, _object), do: middleware
  # coveralls-ignore-stop
end
