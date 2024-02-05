defmodule SupapasskeysWeb.RegistrationControllerTest do
  use SupapasskeysWeb.ConnCase

  @create_attrs %{
    id: Faker.UUID.v4(),
    name: Faker.Internet.email(),
    display_name: Faker.Person.name()
  }
  @invalid_attrs %{id: nil, name: nil, display_name: nil}

  setup %{conn: conn} do
    import Supapasskeys.SupabaseFixtures
    import Supapasskeys.PasskeysFixtures
    project = project_fixture()
    relying_party = relying_party_fixture(project)

    {:ok,
     conn:
       put_req_header(conn, "accept", "application/json")
       |> Map.put(:host, "#{project.reference_id}.example.com"),
     relying_party: relying_party}
  end

  describe "create registration" do
    test "renders registration when data is valid", %{conn: conn, relying_party: relying_party} do
      conn = post(conn, ~p"/passkeys/#{relying_party.id}", @create_attrs)

      assert %{"id" => _id, "creation_options" => _creation_options} =
               json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, relying_party: relying_party} do
      conn = post(conn, ~p"/passkeys/#{relying_party.id}", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
