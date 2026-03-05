defmodule Lifequest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LifequestWeb.Telemetry,
      Lifequest.Repo,
      {DNSCluster, query: Application.get_env(:lifequest, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Lifequest.PubSub},
      # Start a worker by calling: Lifequest.Worker.start_link(arg)
      # {Lifequest.Worker, arg},
      # Start to serve requests, typically the last entry
      LifequestWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lifequest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LifequestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
