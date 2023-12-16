defmodule Supapasskeys.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SupapasskeysWeb.Telemetry,
      Supapasskeys.Repo,
      Supapasskeys.SupabaseRepo,
      {DNSCluster, query: Application.get_env(:supapasskeys, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Supapasskeys.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Supapasskeys.Finch},
      # Start a worker by calling: Supapasskeys.Worker.start_link(arg)
      # {Supapasskeys.Worker, arg},
      # Start to serve requests, typically the last entry
      SupapasskeysWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Supapasskeys.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SupapasskeysWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
