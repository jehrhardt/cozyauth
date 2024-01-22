defmodule SupapasskeysWeb.Plugs.ApiAuthTest do
  alias Supapasskeys.Passkeys
  use SupapasskeysWeb.ConnCase

  setup %{conn: conn} do
    import Supapasskeys.PasskeysFixtures
    server = server_fixture()

    on_exit(fn ->
      Passkeys.delete_server(server)
    end)

    {:ok,
     conn:
       put_req_header(conn, "accept", "application/json")
       |> Map.put(:host, "#{server.subdomain}.example.com"),
     server: server}
  end

  describe "call/2" do
    test "returns 404 Not Found when subdomain is not found", %{conn: conn} do
      invalid_conn = Map.put(conn, :host, "#{Faker.Internet.domain_word()}.example.com")
      conn = SupapasskeysWeb.Plugs.ApiAuth.call(invalid_conn)
      assert json_response(conn, 404)["error"] == "Invalid API domain"
    end

    test "adds server ID and relying party when a valid subdomain is provided", %{
      conn: conn,
      server: server
    } do
      conn = SupapasskeysWeb.Plugs.ApiAuth.call(conn)

      assert conn.status != 404
      assert get_req_header(conn, "x-supapasskeys-server-id") |> List.first() == server.id

      assert get_req_header(conn, "x-supapasskeys-server-relying-party-name") |> List.first() ==
               server.relying_party_name

      assert get_req_header(conn, "x-supapasskeys-server-relying-party-origin") |> List.first() ==
               server.relying_party_origin
    end
  end

  describe "call/2 with invalid api_domain" do
    setup do
      original_config = Application.get_env(:supapasskeys, SupapasskeysWeb.Plugs.ApiAuth)

      Application.put_env(:supapasskeys, SupapasskeysWeb.Plugs.ApiAuth, api_domain: "invalid.com")

      on_exit(fn ->
        Application.put_env(:supapasskeys, SupapasskeysWeb.Plugs.ApiAuth, original_config)
      end)

      :ok
    end

    test "returns 404 Not Found when api domain is incorrect", %{conn: conn} do
      conn = SupapasskeysWeb.Plugs.ApiAuth.call(conn)
      assert json_response(conn, 404)["error"] == "Invalid Subdomain domain"
    end
  end
end
