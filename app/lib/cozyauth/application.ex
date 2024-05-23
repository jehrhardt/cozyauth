defmodule Cozyauth.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CozyauthWeb.Telemetry,
      Cozyauth.Repo,
      {DNSCluster, query: Application.get_env(:cozyauth, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Cozyauth.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Cozyauth.Finch},
      # Start a worker by calling: Cozyauth.Worker.start_link(arg)
      # {Cozyauth.Worker, arg},
      # Start to serve requests, typically the last entry
      CozyauthWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cozyauth.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CozyauthWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
