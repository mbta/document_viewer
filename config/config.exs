# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :document_viewer,
  buckets: [
    %{
      name: "mbta-scans-charlie-card-store",
      excluded_files: [
        "ACKAPP01-493399_TEST.txt",
        "ACKAPP02-496832-TEST.txt",
        "TEST - Copy.txt",
        "TEST.txt"
      ]
    }
  ],
  live_catalog?: true,
  redirect_http?: false,
  cognito_group: "document-viewer"

# Configures the endpoint
config :document_viewer, DocumentViewerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: DocumentViewerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: DocumentViewer.PubSub,
  live_view: [signing_salt: "7iBmI3k6"]

config :document_viewer, DocumentViewerWeb.AuthManager,
  issuer: "document_viewer",
  secret_key: nil

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Placeholder for Keycloak authentication, defined for real in environment configs
config :ueberauth, Ueberauth,
  providers: [
    keycloak: {DocumentViewerWeb.Ueberauth.Strategy.Fake, []}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
