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
          |> put_req_header("x-supapasskeys-server-id", server.id)
          |> put_req_header(
            "x-supapasskeys-server-relying-party-name",
            server.relying_party_name
          )
          |> put_req_header(
            "x-supapasskeys-server-relying-party-origin",
            server.relying_party_origin
          )
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
