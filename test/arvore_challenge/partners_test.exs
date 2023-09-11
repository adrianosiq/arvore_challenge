defmodule ArvoreChallenge.PartnersTest do
  use ArvoreChallenge.DataCase

  alias ArvoreChallenge.Partners

  describe "get_entity/1" do
    test "returns an entity" do
      entity_network = insert!(:entity)

      entity_school =
        insert!(:entity, entity_type: :school, inep: 13_082_175, parent_id: entity_network.id)

      insert!(:entity, entity_type: :class, parent_id: entity_school.id)
      insert!(:entity, entity_type: :class, parent_id: entity_school.id)
      insert!(:entity, entity_type: :class, parent_id: entity_school.id)

      expected_response = ArvoreChallenge.Repo.preload(entity_school, [:parent, :subtree])
      assert Partners.get_entity(entity_school.id) == {:ok, expected_response}
    end

    test "returns an error when the entity is not found" do
      assert Partners.get_entity(1) == {:error, :not_found}
    end

    test "returns an error when entity_id is not an integer" do
      assert Partners.get_entity("invalid_entity_id") == {:error, :bad_request}
    end
  end

  describe "create_entity/1" do
    test "returns an entity of the type network" do
      attrs = %{entity_type: "network", name: "Some Network"}

      assert {:ok, created_entity} = Partners.create_entity(attrs)
      assert created_entity.entity_type == :network
      assert created_entity.name == "Some Network"
    end

    test "returns an error when required fields are empty of the type network" do
      assert {:error, changeset} = Partners.create_entity(%{entity_type: "network"})
      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end

    test "returns an entity of the type a school" do
      attrs = %{entity_type: "school", name: "Some School", inep: "13082175"}

      assert {:ok, created_entity} = Partners.create_entity(attrs)
      assert created_entity.entity_type == :school
      assert created_entity.name == "Some School"
      assert created_entity.inep == 13_082_175
      assert created_entity.parent_id == nil
    end

    test "returns an error when required fields are empty of the type school" do
      assert {:error, changeset} = Partners.create_entity(%{entity_type: "school"})
      assert errors_on(changeset) == %{name: ["can't be blank"], inep: ["can't be blank"]}
    end

    test "returns an error when the parent doesn't exist of the type school" do
      attrs = %{entity_type: "school", name: "Some School", inep: "13082175", parent_id: 1}

      assert {:error, changeset} = Partners.create_entity(attrs)
      assert errors_on(changeset) == %{parent_id: ["does not exist"]}
    end

    test "returns an error when the parent is not network of the type school" do
      invalid_entity_parent = insert!(:entity, entity_type: :class)

      attrs = %{
        entity_type: "school",
        name: "Some School",
        inep: "13082175",
        parent_id: invalid_entity_parent.id
      }

      assert {:error, changeset} = Partners.create_entity(attrs)
      assert errors_on(changeset) == %{parent_id: ["is invalid, the entity type is not network"]}
    end

    test "returns an entity of the type a class" do
      entity_school = insert!(:entity, entity_type: :school, inep: 13_082_175)
      attrs = %{entity_type: "class", name: "Some Class", parent_id: entity_school.id}

      assert {:ok, created_entity} = Partners.create_entity(attrs)
      assert created_entity.entity_type == :class
      assert created_entity.name == "Some Class"
      assert created_entity.parent_id == entity_school.id
      assert created_entity.parent == entity_school
    end

    test "returns an error when required fields are empty of the type class" do
      assert {:error, changeset} = Partners.create_entity(%{entity_type: "class"})
      assert errors_on(changeset) == %{name: ["can't be blank"], parent_id: ["can't be blank"]}
    end

    test "returns an error when the parent doesn't exist of the type class" do
      attrs = %{entity_type: "class", name: "Some Class", parent_id: 1}

      assert {:error, changeset} = Partners.create_entity(attrs)
      assert errors_on(changeset) == %{parent_id: ["does not exist"]}
    end

    test "returns an error when the parent is not school of the type class" do
      invalid_entity_parent = insert!(:entity, entity_type: :network)
      attrs = %{entity_type: "class", name: "Some Class", parent_id: invalid_entity_parent.id}

      assert {:error, changeset} = Partners.create_entity(attrs)
      assert errors_on(changeset) == %{parent_id: ["is invalid, the entity type is not school"]}
    end
  end

  describe "update_entity/2" do
    test "returns an updated entity of the type network" do
      entity = insert!(:entity, entity_type: :network)
      attrs = %{entity_type: "network", name: "Update Some Network"}

      assert {:ok, updated_entity} = Partners.update_entity(entity, attrs)
      assert updated_entity.entity_type == :network
      assert updated_entity.name == "Update Some Network"
    end

    test "returns an error when required fields are empty of the type network" do
      entity = insert!(:entity, entity_type: :network)

      assert {:error, changeset} =
               Partners.update_entity(entity, %{entity_type: "network", name: nil})

      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end

    test "returns an updated entity of the type a school" do
      entity = insert!(:entity, entity_type: :school, inep: 13_082_175)
      attrs = %{entity_type: "school", name: "Update Some School", inep: "13882975"}

      assert {:ok, updated_entity} = Partners.update_entity(entity, attrs)
      assert updated_entity.entity_type == :school
      assert updated_entity.name == "Update Some School"
      assert updated_entity.inep == 13_882_975
      assert updated_entity.parent_id == nil
    end

    test "returns an error when required fields are empty of the type school" do
      entity = insert!(:entity, entity_type: :school, inep: 13_082_175)

      assert {:error, changeset} =
               Partners.update_entity(entity, %{entity_type: "school", name: nil, inep: nil})

      assert errors_on(changeset) == %{name: ["can't be blank"], inep: ["can't be blank"]}
    end

    test "returns an error when the parent doesn't exist of the type school" do
      entity = insert!(:entity, entity_type: :school, inep: 13_082_175)
      attrs = %{entity_type: "school", name: "Update Some School", inep: "13882975", parent_id: 1}

      assert {:error, changeset} = Partners.update_entity(entity, attrs)
      assert errors_on(changeset) == %{parent_id: ["does not exist"]}
    end

    test "returns an error when the parent is not network of the type school" do
      entity = insert!(:entity, entity_type: :school, inep: 13_082_175)
      invalid_entity_parent = insert!(:entity, entity_type: :class)

      attrs = %{
        entity_type: "school",
        name: "Update Some School",
        inep: "13882975",
        parent_id: invalid_entity_parent.id
      }

      assert {:error, changeset} = Partners.update_entity(entity, attrs)
      assert errors_on(changeset) == %{parent_id: ["is invalid, the entity type is not network"]}
    end

    test "returns an updated entity of the type a class" do
      entity_school = insert!(:entity, entity_type: :school, inep: 13_082_175)
      entity = insert!(:entity, entity_type: :class, parent_id: entity_school.id)
      update_entity_school = insert!(:entity, entity_type: :school, inep: 13_072_175)

      attrs = %{
        entity_type: "class",
        name: "Update Some Class",
        parent_id: update_entity_school.id
      }

      assert {:ok, updated_entity} = Partners.update_entity(entity, attrs)
      assert updated_entity.entity_type == :class
      assert updated_entity.name == "Update Some Class"
      assert updated_entity.parent_id == update_entity_school.id
      assert updated_entity.parent == update_entity_school
    end

    test "returns an error when required fields are empty of the type class" do
      entity_school = insert!(:entity, entity_type: :school, inep: 13_082_175)
      entity = insert!(:entity, entity_type: :class, parent_id: entity_school.id)

      assert {:error, changeset} =
               Partners.update_entity(entity, %{entity_type: "class", name: nil, parent_id: nil})

      assert errors_on(changeset) == %{name: ["can't be blank"], parent_id: ["can't be blank"]}
    end

    test "returns an error when the parent doesn't exist of the type class" do
      entity = insert!(:entity, entity_type: :class)
      attrs = %{entity_type: "class", name: "Update Some Class", parent_id: 1}

      assert {:error, changeset} = Partners.update_entity(entity, attrs)
      assert errors_on(changeset) == %{parent_id: ["does not exist"]}
    end

    test "returns an error when the parent is not school of the type class" do
      entity = insert!(:entity, entity_type: :class)
      invalid_entity_parent = insert!(:entity, entity_type: :network)
      attrs = %{entity_type: "class", name: "Some Class", parent_id: invalid_entity_parent.id}

      assert {:error, changeset} = Partners.update_entity(entity, attrs)
      assert errors_on(changeset) == %{parent_id: ["is invalid, the entity type is not school"]}
    end
  end
end
