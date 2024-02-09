defmodule SupapasskeysWeb.Plugs.ApiAuth do
  alias Supapasskeys.Servers
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(options), do: options

  @impl true
  def call(conn, _options \\ %{}) do
    api_domain =
      Application.get_env(:supapasskeys, SupapasskeysWeb.Plugs.ApiAuth)
      |> Keyword.get(:api_domain)

    case api_domain do
      nil ->
        conn
        |> put_req_header(
          "x-supabase-reference-id",
          Application.get_env(:supapasskeys, :supabase_project_id)
        )

      _ ->
        if String.ends_with?(conn.host, api_domain) do
          server =
            conn.host
            |> String.replace(".#{api_domain}", "")
            |> Servers.get_server_by_subdomain()

          case server do
            nil ->
              conn
              |> put_status(404)
              |> put_resp_header("content-type", "application/json")
              |> Phoenix.Controller.json(%{error: "Invalid API domain"})
              |> halt()

            _ ->
              conn
              |> put_req_header("x-supabase-reference-id", server.subdomain)
          end
        else
          conn
          |> put_status(404)
          |> put_resp_header("content-type", "application/json")
          |> Phoenix.Controller.json(%{error: "Invalid Subdomain domain"})
          |> halt()
        end
    end
  end
end
