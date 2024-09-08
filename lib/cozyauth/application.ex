defmodule CozyAuth.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CozyAuthWeb.Telemetry,
      CozyAuth.Repo,
      {DNSCluster, query: Application.get_env(:cozyauth, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CozyAuth.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CozyAuth.Finch},
      # Start a worker by calling: CozyAuth.Worker.start_link(arg)
      # {CozyAuth.Worker, arg},
      # Start to serve requests, typically the last entry
      CozyAuthWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CozyAuth.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CozyAuthWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
