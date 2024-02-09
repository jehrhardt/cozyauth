defmodule SupapasskeysWeb.RegistrationControllerTest do
  use SupapasskeysWeb.ConnCase

  @create_attrs %{
    id: Faker.UUID.v4(),
    name: Faker.Internet.email(),
    display_name: Faker.Person.name()
  }
  @invalid_attrs %{id: nil, name: nil, display_name: nil}

  describe "create registration with multi server enabled" do
    setup %{conn: conn} do
      import Supapasskeys.ServersFixtures
      import Supapasskeys.PasskeysFixtures
      server = server_fixture()
      relying_party = relying_party_fixture(server)

      {:ok,
       conn:
         put_req_header(conn, "accept", "application/json")
         |> Map.put(:host, "#{server.subdomain}.example.com"),
       relying_party: relying_party}
    end

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

  describe "create registration with multi server disabled" do
    setup %{conn: conn} do
      import Supapasskeys.PasskeysFixtures
      original_config = Application.get_env(:supapasskeys, :multi_server_enabled)

      Application.put_env(:supapasskeys, :multi_server_enabled, false)

      on_exit(fn ->
        Application.put_env(:supapasskeys, :multi_server_enabled, original_config)
      end)

      relying_party = relying_party_fixture(nil)

      {:ok,
       conn: put_req_header(conn, "accept", "application/json"), relying_party: relying_party}
    end

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
