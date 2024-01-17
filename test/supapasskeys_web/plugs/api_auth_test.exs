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

      conn =
        SupapasskeysWeb.Plugs.ApiAuth.call(invalid_conn,
          api_domain: "example.com",
          multi_tenancy: true
        )

      assert json_response(conn, 404)["error"] == "Invalid API domain"
    end

    test "returns 404 Not Found when api domain is incorrect", %{conn: conn} do
      conn =
        SupapasskeysWeb.Plugs.ApiAuth.call(conn, api_domain: "incorrect.com", multi_tenancy: true)

      assert json_response(conn, 404)["error"] == "Invalid Subdomain domain"
    end

    test "adds server ID and relying party when a valid subdomain is provided", %{
      conn: conn,
      server: server
    } do
      conn =
        SupapasskeysWeb.Plugs.ApiAuth.call(conn, api_domain: "example.com", multi_tenancy: true)

      assert conn.status != 404
      assert get_req_header(conn, "x-supapasskeys-server-id") |> List.first() == server.id

      assert get_req_header(conn, "x-supapasskeys-server-relying-party-name") |> List.first() ==
               server.relying_party_name

      assert get_req_header(conn, "x-supapasskeys-server-relying-party-origin") |> List.first() ==
               server.relying_party_origin
    end

    test "adds relying party when multi tenancy is disabled", %{conn: conn} do
      conn =
        SupapasskeysWeb.Plugs.ApiAuth.call(conn, api_domain: "example.com", multi_tenancy: false)

      assert conn.status != 404

      assert get_req_header(conn, "x-supapasskeys-server-relying-party-name") |> List.first() ==
               "Supapasskeys"

      assert get_req_header(conn, "x-supapasskeys-server-relying-party-origin") |> List.first() ==
               "http://localhost:4000"
    end
  end

  describe "init/1" do
    test "sets api domain from config" do
      assert [api_domain: "example.com", multi_tenancy: false] ==
               SupapasskeysWeb.Plugs.ApiAuth.init([])
    end
  end
end
