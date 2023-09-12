defmodule ArvoreChallenge.AuthorizationsTest do
  use ArvoreChallenge.DataCase

  alias ArvoreChallenge.Authorizations
  alias ArvoreChallenge.Authorizations.Guardian

  describe "encode_and_sign/1" do
    test "returns an access token" do
      entity = insert!(:entity)

      assert {:ok, access_token, %{"exp" => exp, "iat" => iat, "typ" => typ}} =
               Authorizations.encode_and_sign(entity)

      assert {:ok, _claims} = Guardian.decode_and_verify(access_token)
      assert is_integer(exp)
      assert is_integer(iat)
      assert typ == "Bearer"
    end

    test "retruns an error" do
      assert Authorizations.encode_and_sign(%{}) == {:error, :unauthorized}
    end
  end
end
