defmodule ArvoreChallengeWeb.Resolvers.Authorizations.Authorization do
  @moduledoc false

  alias Absinthe.Resolution
  alias ArvoreChallenge.Authorizations
  alias ArvoreChallenge.Partners
  alias ArvoreChallenge.Partners.Entity

  @spec auhorization(map(), Resolution.t()) :: {:ok, map()} | {:error, atom()}
  def auhorization(%{access_key: access_key, secret_access_key: secret_access_key}, _resolution) do
    with {:ok, %Entity{} = entity} <-
           Partners.get_entity_by_access_key_and_secret_access_key(access_key, secret_access_key),
         {:ok, access_token, claims} <- Authorizations.encode_and_sign(entity) do
      {:ok, build_response(access_token, claims)}
    else
      _ -> {:error, :unauthorized}
    end
  end

  defp build_response(access_token, %{"exp" => exp, "iat" => iat, "typ" => typ}) do
    %{
      access_token: access_token,
      expires_in: exp - iat,
      token_type: typ
    }
  end
end
