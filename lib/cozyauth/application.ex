# Copyright (C) 2024 Cozy Auth Contributors
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

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
