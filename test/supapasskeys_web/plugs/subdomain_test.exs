defmodule SupapasskeysWeb.Plugs.SubdomainTest do
  alias Supapasskeys.Servers
  use SupapasskeysWeb.ConnCase

  setup %{conn: conn} do
    import Supapasskeys.ServersFixtures
    server = server_fixture()

    on_exit(fn ->
      Servers.delete_server(server)
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
      conn = SupapasskeysWeb.Plugs.Subdomain.call(invalid_conn)
      assert json_response(conn, 404)["error"] == "Invalid API domain"
    end

    test "adds subdomain header when a valid subdomain is provided", %{
      conn: conn,
      server: server
    } do
      conn = SupapasskeysWeb.Plugs.Subdomain.call(conn)

      assert get_req_header(conn, "x-subdomain") |> List.first() ==
               server.subdomain
    end
  end

  describe "call/2 with invalid api_domain" do
    setup do
      original_config = Application.get_env(:supapasskeys, SupapasskeysWeb.Plugs.Subdomain)

      Application.put_env(:supapasskeys, SupapasskeysWeb.Plugs.Subdomain,
        api_domain: "invalid.com"
      )

      on_exit(fn ->
        Application.put_env(:supapasskeys, SupapasskeysWeb.Plugs.Subdomain, original_config)
      end)

      :ok
    end

    test "returns 404 Not Found when api domain is incorrect", %{conn: conn} do
      conn = SupapasskeysWeb.Plugs.Subdomain.call(conn)
      assert json_response(conn, 404)["error"] == "Invalid Subdomain domain"
    end
  end

  describe "call/2 with multi server disabled" do
    setup do
      original_config = Application.get_env(:supapasskeys, :multi_server_enabled)

      Application.put_env(:supapasskeys, :multi_server_enabled, false)

      on_exit(fn ->
        Application.put_env(:supapasskeys, :multi_server_enabled, original_config)
      end)

      :ok
    end

    test "adds no subdomain header", %{conn: conn} do
      conn = SupapasskeysWeb.Plugs.Subdomain.call(conn)
      assert is_nil(get_req_header(conn, "x-subdomain") |> List.first())
    end
  end
end
