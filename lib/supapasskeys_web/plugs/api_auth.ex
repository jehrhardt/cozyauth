defmodule SupapasskeysWeb.Plugs.ApiAuth do
  alias Supapasskeys.Passkeys
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(options) do
    api_domain =
      Application.get_env(:supapasskeys, SupapasskeysWeb.Plugs.ApiAuth)
      |> Keyword.get(:api_domain)

    multi_tenancy =
      Application.get_env(:supapasskeys, SupapasskeysWeb.Plugs.ApiAuth)
      |> Keyword.get(:multi_tenancy)

    options
    |> Keyword.put(:multi_tenancy, multi_tenancy)
    |> Keyword.put(:api_domain, api_domain)
  end

  @impl true
  def call(conn, options) do
    case options do
      [api_domain: _, multi_tenancy: false] ->
        relying_party_name =
          Application.get_env(:supapasskeys, Supapasskeys.Passkeys)
          |> Keyword.get(:relying_party_name)

        relying_party_origin =
          Application.get_env(:supapasskeys, Supapasskeys.Passkeys)
          |> Keyword.get(:relying_party_origin)

        conn
        |> put_req_header("x-supapasskeys-server-relying-party-name", relying_party_name)
        |> put_req_header("x-supapasskeys-server-relying-party-origin", relying_party_origin)

      [api_domain: api_domain, multi_tenancy: true] ->
        if String.ends_with?(conn.host, api_domain) do
          server =
            conn.host
            |> String.replace(".#{api_domain}", "")
            |> Passkeys.get_server_by_subdomain()

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
end
