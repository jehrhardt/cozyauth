defmodule SupapasskeysWeb.RegistrationControllerTest do
  use SupapasskeysWeb.ConnCase

  @create_attrs %{
    id: Faker.UUID.v4(),
    name: Faker.Internet.email(),
    display_name: Faker.Person.name()
  }
  @invalid_attrs %{id: nil, name: nil, display_name: nil}

  setup %{conn: conn} do
    import Supapasskeys.ServersFixtures
    server = server_fixture()

    {:ok,
     conn:
       put_req_header(conn, "accept", "application/json")
       |> Map.put(:host, "#{server.subdomain}.example.com")}
  end

  describe "create registration" do
    test "renders registration when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/passkeys", @create_attrs)

      assert %{"id" => _id, "creation_options" => _creation_options} =
               json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/passkeys", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
