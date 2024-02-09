defmodule SupapasskeysWeb.Plugs.Subdomain do
  alias Supapasskeys.Servers
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(options), do: options

  @impl true
  def call(conn, _options \\ %{}) do
    api_domain =
      Application.get_env(:supapasskeys, SupapasskeysWeb.Plugs.Subdomain)
      |> Keyword.get(:api_domain)

    if Application.get_env(:supapasskeys, :multi_server_enabled) do
      extract_and_put_subdomain_header(conn, api_domain)
    else
      conn
    end
  end

  defp extract_and_put_subdomain_header(conn, api_domain) do
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
          |> put_req_header("x-subdomain", server.subdomain)
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
