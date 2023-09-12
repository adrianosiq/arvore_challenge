defmodule ArvoreChallenge.Authorizations do
  @moduledoc false

  alias ArvoreChallenge.Authorizations.Guardian
  alias ArvoreChallenge.Partners.Entity

  @spec encode_and_sign(Entity.t()) :: {:ok, map()} | {:error, term()}
  def encode_and_sign(%Entity{} = entity),
    do: Guardian.encode_and_sign(entity, %{}, token_type: "Bearer")

  def encode_and_sign(_), do: {:error, :unauthorized}
end
