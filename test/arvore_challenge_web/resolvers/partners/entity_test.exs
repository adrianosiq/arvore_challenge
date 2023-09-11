defmodule ArvoreChallengeWeb.Resolvers.Partners.EntityTest do
  use ArvoreChallenge.DataCase

  alias ArvoreChallengeWeb.Resolvers.Partners.Entity

  describe "get_entity/2" do
    test "returns an entity" do
      entity_network = insert!(:entity)

      entity_school =
        insert!(:entity, entity_type: :school, inep: 13_082_175, parent_id: entity_network.id)

      insert!(:entity, entity_type: :class, parent_id: entity_school.id)
      insert!(:entity, entity_type: :class, parent_id: entity_school.id)
      insert!(:entity, entity_type: :class, parent_id: entity_school.id)

      expected_response = ArvoreChallenge.Repo.preload(entity_school, [:parent, :subtree])

      assert Entity.get_entity(%{id: entity_school.id}, %Absinthe.Resolution{}) ==
               {:ok,
                %{
                  id: expected_response.id,
                  entity_type: to_string(expected_response.entity_type),
                  inep: expected_response.inep,
                  name: expected_response.name,
                  parent_id: expected_response.parent_id,
                  subtree_ids:
                    Enum.map(expected_response.subtree, fn %{id: subtree_id} -> subtree_id end)
                }}
    end

    test "returns an error when the entity is not found" do
      assert Entity.get_entity(%{id: 1}, %Absinthe.Resolution{}) == {:error, :not_found}
    end

    test "returns an error when entity_id is not an integer" do
      assert Entity.get_entity(%{id: "invalid_partner_id"}, %Absinthe.Resolution{}) ==
               {:error, :bad_request}
    end
  end

  describe "create_entity/2" do
    test "returns an entity" do
      entity_school = insert!(:entity, entity_type: :school, inep: 13_082_175)
      attrs = %{entity_type: "class", name: "Some Class", parent_id: entity_school.id}

      assert {:ok, created_entity} = Entity.create_entity(attrs, %Absinthe.Resolution{})
      assert is_integer(created_entity.id)
      assert created_entity.entity_type == "class"
      assert created_entity.name == "Some Class"
      assert created_entity.parent_id == entity_school.id
      assert created_entity.subtree_ids == []
    end

    test "returns an error" do
      assert {:error, changeset} = Entity.create_entity(%{}, %Absinthe.Resolution{})
      assert errors_on(changeset) == %{entity_type: ["can't be blank"], name: ["can't be blank"]}
    end
  end

  describe "update_entity/3" do
    test "returns an entity" do
      entity_network = insert!(:entity)

      entity_school =
        insert!(:entity, entity_type: :school, inep: 13_082_175, parent_id: entity_network.id)

      insert!(:entity, entity_type: :class, parent_id: entity_school.id)
      insert!(:entity, entity_type: :class, parent_id: entity_school.id)
      insert!(:entity, entity_type: :class, parent_id: entity_school.id)

      entity = insert!(:entity, entity_type: :class, parent_id: entity_school.id)
      update_entity_school = insert!(:entity, entity_type: :school, inep: 13_072_175)

      attrs = %{
        id: entity.id,
        name: "Update Some Class",
        parent_id: update_entity_school.id
      }

      expected_response = ArvoreChallenge.Repo.preload(entity, [:parent, :subtree])

      assert Entity.update_entity(attrs, %Absinthe.Resolution{}) ==
               {:ok,
                %{
                  id: expected_response.id,
                  entity_type: "class",
                  inep: nil,
                  name: attrs[:name],
                  parent_id: attrs[:parent_id],
                  subtree_ids:
                    Enum.map(expected_response.subtree, fn %{id: subtree_id} -> subtree_id end)
                }}
    end

    test "returns an error when the entity is not found" do
      assert Entity.update_entity(%{id: 1}, %Absinthe.Resolution{}) == {:error, :not_found}
    end

    test "returns an error" do
      entity = insert!(:entity)
      attrs = %{id: entity.id, entity_type: nil, name: nil}

      assert {:error, changeset} = Entity.update_entity(attrs, %Absinthe.Resolution{})
      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end
  end
end
