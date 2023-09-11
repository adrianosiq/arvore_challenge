defmodule ArvoreChallenge.Partners.EntityTest do
  use ArvoreChallenge.DataCase, async: true

  alias ArvoreChallenge.Partners.Entity

  describe "changeset/2" do
    test "returns valid changeset" do
      changeset =
        Entity.changeset(%Entity{}, %{
          entity_type: "network",
          name: "Some Network"
        })

      assert changeset.valid?
      assert changeset.changes == %{entity_type: :network, name: "Some Network"}
    end

    test "validate entity type inclusion" do
      changeset =
        Entity.changeset(%Entity{}, %{
          entity_type: "invalid_entity_type",
          name: "Some Entity"
        })

      refute changeset.valid?
      assert errors_on(changeset) == %{entity_type: ["is invalid"]}
    end

    test "validate required fields" do
      changeset = Entity.changeset(%Entity{}, %{})

      refute changeset.valid?
      assert errors_on(changeset) == %{entity_type: ["can't be blank"], name: ["can't be blank"]}
    end
  end
end
