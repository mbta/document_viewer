# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

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
  live_catalog?: true

# Configures the endpoint
config :document_viewer, DocumentViewerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "GQz2AbfSliQp6FYTncpcZJgM7skJdhKH6refgghsdE9gOz0TQ5u5+Er+tzH6XmUt",
  render_errors: [view: DocumentViewerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: DocumentViewer.PubSub,
  live_view: [signing_salt: "7iBmI3k6"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
