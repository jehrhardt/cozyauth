defmodule SupapasskeysWeb.Plugs.ApiAuthTest do
  alias Supapasskeys.Supabase
  use SupapasskeysWeb.ConnCase

  setup %{conn: conn} do
    import Supapasskeys.SupabaseFixtures
    project = project_fixture()

    on_exit(fn ->
      Supabase.delete_project(project)
    end)

    {:ok,
     conn:
       put_req_header(conn, "accept", "application/json")
       |> Map.put(:host, "#{project.reference_id}.example.com"),
     project: project}
  end

  describe "call/2" do
    test "returns 404 Not Found when subdomain is not found", %{conn: conn} do
      invalid_conn = Map.put(conn, :host, "#{Faker.Internet.domain_word()}.example.com")
      conn = SupapasskeysWeb.Plugs.ApiAuth.call(invalid_conn)
      assert json_response(conn, 404)["error"] == "Invalid API domain"
    end

    test "adds project ID and relying party when a valid subdomain is provided", %{
      conn: conn,
      project: project
    } do
      conn = SupapasskeysWeb.Plugs.ApiAuth.call(conn)

      assert conn.status != 404

      assert get_req_header(conn, "x-supabase-reference-id") |> List.first() ==
               project.reference_id
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
