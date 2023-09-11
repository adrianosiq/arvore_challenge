defmodule ArvoreChallengeWeb.SchemaTest do
  use ArvoreChallengeWeb.ConnCase, async: true

  describe "query: entity" do
    @entity_query """
    query getEntity($id: Int!) {
      entity(id: $id) {
        id
        entity_type
        inep
        name
        parent_id
        subtree_ids
      }
    }
    """

    test "returns an entity", %{conn: conn} do
      entity_network = insert!(:entity)

      entity_school =
        insert!(:entity, entity_type: :school, inep: 13_082_175, parent_id: entity_network.id)

      insert!(:entity, entity_type: :class, parent_id: entity_school.id)
      insert!(:entity, entity_type: :class, parent_id: entity_school.id)
      insert!(:entity, entity_type: :class, parent_id: entity_school.id)

      entity = ArvoreChallenge.Repo.preload(entity_school, [:parent, :subtree])
      conn = post(conn, ~p"/api", %{"query" => @entity_query, "variables" => %{id: entity.id}})

      assert %{"entity" => response} = json_response(conn, 200)["data"]
      assert response["id"] == entity.id
      assert response["entity_type"] == to_string(entity.entity_type)
      assert response["inep"] == entity.inep
      assert response["name"] == entity.name
      assert response["parent_id"] == entity.parent_id

      assert response["subtree_ids"] ==
               Enum.map(entity.subtree, fn %{id: subtree_id} -> subtree_id end)
    end

    test "returns an error when not exists entity", %{conn: conn} do
      conn = post(conn, ~p"/api", %{"query" => @entity_query, "variables" => %{id: 1}})
      assert [%{"message" => message}] = json_response(conn, 200)["errors"]
      assert message == "Resource not found"
    end

    test "returns an error when invalid entity", %{conn: conn} do
      conn = post(conn, ~p"/api", %{"query" => @entity_query, "variables" => %{id: "invalid_id"}})

      assert [%{"message" => message}] = json_response(conn, 200)["errors"]
      assert message == "Argument \"id\" has invalid value $id."
    end
  end

  describe "mutation: create_entity" do
    @create_entity """
    mutation CreateEntity($name: String!, $entity_type: String!, $inep: String, $parent_id: Int) {
      createEntity(name: $name, entity_type: $entity_type, inep: $inep, parent_id: $parent_id) {
        id
        entity_type
        inep
        name
        parent_id
        subtree_ids
      }
    }
    """

    test "returns an entity of the type network", %{conn: conn} do
      attrs = %{entity_type: "network", name: "Some Network"}
      conn = post(conn, ~p"/api", %{"query" => @create_entity, "variables" => attrs})

      assert %{"createEntity" => response} = json_response(conn, 200)["data"]
      assert is_integer(response["id"])
      assert response["entity_type"] == "network"
      assert response["name"] == "Some Network"
      assert is_nil(response["inep"])
      assert is_nil(response["parent_id"])
      assert response["subtree_ids"] == []
    end

    test "returns an entity of the type a school", %{conn: conn} do
      attrs = %{entity_type: "school", name: "Some School", inep: "13082175"}
      conn = post(conn, ~p"/api", %{"query" => @create_entity, "variables" => attrs})

      assert %{"createEntity" => response} = json_response(conn, 200)["data"]
      assert is_integer(response["id"])
      assert response["entity_type"] == "school"
      assert response["name"] == "Some School"
      assert response["inep"] == 13_082_175
      assert is_nil(response["parent_id"])
      assert response["subtree_ids"] == []
    end

    test "returns an error when the parent doesn't exist of the type school", %{conn: conn} do
      attrs = %{entity_type: "school", name: "Some School", inep: "13082175", parent_id: 1}
      conn = post(conn, ~p"/api", %{"query" => @create_entity, "variables" => attrs})

      assert [%{"message" => message}] = json_response(conn, 200)["errors"]
      assert message == "Parent_id does not exist"
    end

    test "returns an error when the parent is not network of the type school", %{conn: conn} do
      invalid_entity_parent = insert!(:entity, entity_type: :class)

      attrs = %{
        entity_type: "school",
        name: "Some School",
        inep: "13082175",
        parent_id: invalid_entity_parent.id
      }

      conn = post(conn, ~p"/api", %{"query" => @create_entity, "variables" => attrs})

      assert [%{"message" => message}] = json_response(conn, 200)["errors"]
      assert message == "Parent_id is invalid, the entity type is not network"
    end

    test "returns an entity of the type a class", %{conn: conn} do
      entity_school = insert!(:entity, entity_type: :school, inep: 13_082_175)
      attrs = %{entity_type: "class", name: "Some Class", parent_id: entity_school.id}
      conn = post(conn, ~p"/api", %{"query" => @create_entity, "variables" => attrs})

      assert %{"createEntity" => response} = json_response(conn, 200)["data"]
      assert is_integer(response["id"])
      assert response["entity_type"] == "class"
      assert response["name"] == "Some Class"
      assert is_nil(response["inep"])
      assert response["parent_id"] == entity_school.id
      assert response["subtree_ids"] == []
    end

    test "returns an error when the parent doesn't exist of the type class", %{conn: conn} do
      attrs = %{entity_type: "class", name: "Some Class", parent_id: 1}
      conn = post(conn, ~p"/api", %{"query" => @create_entity, "variables" => attrs})

      assert [%{"message" => message}] = json_response(conn, 200)["errors"]
      assert message == "Parent_id does not exist"
    end

    test "returns an error when the parent is not school of the type class", %{conn: conn} do
      invalid_entity_parent = insert!(:entity, entity_type: :network)
      attrs = %{entity_type: "class", name: "Some Class", parent_id: invalid_entity_parent.id}
      conn = post(conn, ~p"/api", %{"query" => @create_entity, "variables" => attrs})

      assert [%{"message" => message}] = json_response(conn, 200)["errors"]
      assert message == "Parent_id is invalid, the entity type is not school"
    end
  end

  describe "mutation: update_entity" do
    @update_entity """
    mutation UpdateEntity($id: Int!, $name: String!, $inep: String, $parent_id: Int) {
      updateEntity(id: $id, name: $name, inep: $inep, parent_id: $parent_id) {
        id
        entity_type
        inep
        name
        parent_id
        subtree_ids
      }
    }
    """

    test "returns an updated entity of the type network", %{conn: conn} do
      entity = insert!(:entity, entity_type: :network)
      attrs = %{id: entity.id, name: "Update Some Network"}
      conn = post(conn, ~p"/api", %{"query" => @update_entity, "variables" => attrs})

      assert %{"updateEntity" => response} = json_response(conn, 200)["data"]
      assert is_integer(response["id"])
      assert response["entity_type"] == "network"
      assert response["name"] == "Update Some Network"
      assert is_nil(response["inep"])
      assert is_nil(response["parent_id"])
      assert response["subtree_ids"] == []
    end

    test "returns an updated entity of the type a school", %{conn: conn} do
      entity = insert!(:entity, entity_type: :school, inep: 13_082_175)
      attrs = %{id: entity.id, name: "Update Some School", inep: "13882975"}
      conn = post(conn, ~p"/api", %{"query" => @update_entity, "variables" => attrs})

      assert %{"updateEntity" => response} = json_response(conn, 200)["data"]
      assert is_integer(response["id"])
      assert response["entity_type"] == "school"
      assert response["name"] == "Update Some School"
      assert response["inep"] == 13_882_975
      assert is_nil(response["parent_id"])
      assert response["subtree_ids"] == []
    end

    test "returns an error when the parent doesn't exist of the type school", %{conn: conn} do
      entity = insert!(:entity, entity_type: :school, inep: 13_082_175)
      attrs = %{id: entity.id, name: "Update Some School", inep: "13882975", parent_id: 1}
      conn = post(conn, ~p"/api", %{"query" => @update_entity, "variables" => attrs})

      assert [%{"message" => message}] = json_response(conn, 200)["errors"]
      assert message == "Parent_id does not exist"
    end

    test "returns an error when the parent is not network of the type school", %{conn: conn} do
      entity = insert!(:entity, entity_type: :school, inep: 13_082_175)
      invalid_entity_parent = insert!(:entity, entity_type: :class)

      attrs = %{
        id: entity.id,
        name: "Update Some School",
        inep: "13882975",
        parent_id: invalid_entity_parent.id
      }

      conn = post(conn, ~p"/api", %{"query" => @update_entity, "variables" => attrs})

      assert [%{"message" => message}] = json_response(conn, 200)["errors"]
      assert message == "Parent_id is invalid, the entity type is not network"
    end

    test "returns an updated entity of the type a class", %{conn: conn} do
      entity_school = insert!(:entity, entity_type: :school, inep: 13_082_175)
      entity = insert!(:entity, entity_type: :class, parent_id: entity_school.id)
      update_entity_school = insert!(:entity, entity_type: :school, inep: 13_072_175)
      attrs = %{id: entity.id, name: "Update Some Class", parent_id: update_entity_school.id}
      conn = post(conn, ~p"/api", %{"query" => @update_entity, "variables" => attrs})

      assert %{"updateEntity" => response} = json_response(conn, 200)["data"]
      assert is_integer(response["id"])
      assert response["entity_type"] == "class"
      assert response["name"] == "Update Some Class"
      assert is_nil(response["inep"])
      assert response["parent_id"] == update_entity_school.id
      assert response["subtree_ids"] == []
    end

    test "returns an error when the parent doesn't exist of the type class", %{conn: conn} do
      entity = insert!(:entity, entity_type: :class)
      attrs = %{id: entity.id, name: "Update Some Class", parent_id: 1}
      conn = post(conn, ~p"/api", %{"query" => @update_entity, "variables" => attrs})

      assert [%{"message" => message}] = json_response(conn, 200)["errors"]
      assert message == "Parent_id does not exist"
    end

    test "returns an error when the parent is not school of the type class", %{conn: conn} do
      entity = insert!(:entity, entity_type: :class)
      invalid_entity_parent = insert!(:entity, entity_type: :network)
      attrs = %{id: entity.id, name: "Update Some Class", parent_id: invalid_entity_parent.id}
      conn = post(conn, ~p"/api", %{"query" => @update_entity, "variables" => attrs})

      assert [%{"message" => message}] = json_response(conn, 200)["errors"]
      assert message == "Parent_id is invalid, the entity type is not school"
    end
  end
end
