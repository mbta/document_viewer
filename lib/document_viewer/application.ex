defmodule DocumentViewer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      DocumentViewerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: DocumentViewer.PubSub},
      {Catalog, name: Catalog},
      # Start the Endpoint (http/https)
      DocumentViewerWeb.Endpoint
      # Start a worker by calling: DocumentViewer.Worker.start_link(arg)
      # {DocumentViewer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DocumentViewer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DocumentViewerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
