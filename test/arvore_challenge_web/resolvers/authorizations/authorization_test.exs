defmodule ArvoreChallengeWeb.Resolvers.Authorizations.AuthorizationTest do
  use ArvoreChallenge.DataCase

  alias ArvoreChallenge.Authorizations.Guardian
  alias ArvoreChallengeWeb.Resolvers.Authorizations.Authorization

  describe "auhorization/2" do
    test "returns an access token" do
      entity = insert!(:entity)
      attrs = %{access_key: entity.access_key, secret_access_key: entity.secret_access_key}

      assert {:ok, response} = Authorization.auhorization(attrs, %Absinthe.Resolution{})
      assert {:ok, _claims} = Guardian.decode_and_verify(response.access_token)
      assert response.expires_in == 86_400
      assert response.token_type == "Bearer"
    end

    test "returns an error when not authorizer" do
      assert Authorization.auhorization(
               %{access_key: "XYZ", secret_access_key: "ABCDEF"},
               %Absinthe.Resolution{}
             ) == {:error, :unauthorized}
    end
  end
end
