defmodule ArvoreChallenge.Authorizations.Guardian do
  @moduledoc false

  use Guardian, otp_app: :arvore_challenge

  alias ArvoreChallenge.Partners
  alias ArvoreChallenge.Partners.Entity

  @spec subject_for_token(Entity.t(), Map.t()) :: {:ok, String.t()}
  def subject_for_token(%{id: id}, _claims), do: {:ok, id}
  def subject_for_token(_entity, _claims), do: {:error, :not_found}

  @spec resource_from_claims(Map.t()) :: Entity.t()
  def resource_from_claims(%{"sub" => id}), do: Partners.get_entity(id)
  def resource_from_claims(_claims), do: {:error, :malformed}
end
