defmodule SupapasskeysWeb.ApiAuth do
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    api_domain =
      Application.get_env(:supapasskeys, SupapasskeysWeb.ApiAuth)
      |> Keyword.get(:api_domain)

    case conn.host do
      ^api_domain ->
        conn

      _ ->
        conn
        |> put_status(404)
        |> put_resp_header("content-type", "application/json")
        |> Phoenix.Controller.json(%{error: "Invalid API domain"})
        |> halt()
    end
  end
end
