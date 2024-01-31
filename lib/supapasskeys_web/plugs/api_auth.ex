defmodule SupapasskeysWeb.Plugs.ApiAuth do
  alias Supapasskeys.Supabase
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
      project =
        conn.host
        |> String.replace(".#{api_domain}", "")
        |> Supabase.get_project_by_reference_id()

      case project do
        nil ->
          conn
          |> put_status(404)
          |> put_resp_header("content-type", "application/json")
          |> Phoenix.Controller.json(%{error: "Invalid API domain"})
          |> halt()

        _ ->
          conn
          |> put_req_header("x-supabase-reference-id", project.reference_id)
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
