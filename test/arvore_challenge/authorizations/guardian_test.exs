defmodule ArvoreChallenge.Authorizations.GuardianTest do
  use ArvoreChallenge.DataCase

  alias ArvoreChallenge.Authorizations.Guardian
  alias ArvoreChallenge.Partners.Entity

  describe "subject_for_token/2" do
    test "returns a entity id" do
      assert Guardian.subject_for_token(%Entity{id: 1}, %{}) == {:ok, 1}
    end

    test "returns an error" do
      assert Guardian.subject_for_token(%{}, %{}) == {:error, :not_found}
    end
  end

  describe "resource_from_claims/1" do
    test "returns a entity" do
      entity = insert!(:entity)
      expected_response = ArvoreChallenge.Repo.preload(entity, [:parent, :subtree])

      assert Guardian.resource_from_claims(%{"sub" => entity.id}) == {:ok, expected_response}
    end

    test "returns an error when the entity not exists" do
      assert {:error, :not_found} == Guardian.resource_from_claims(%{"sub" => 1})
    end

    test "returns an error when the claims is malformed" do
      assert {:error, :malformed} == Guardian.resource_from_claims(%{})
    end
  end
end
