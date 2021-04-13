use Mix.Config

config :document_viewer,
  live_catalog?: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :document_viewer, DocumentViewerWeb.Endpoint,
  http: [port: 4002],
  server: false

config :document_viewer, DocumentViewerWeb.AuthManager, secret_key: "test key"

config :ueberauth, Ueberauth,
  providers: [
    cognito: {DocumentViewerWeb.Ueberauth.Strategy.Fake, []}
  ]

# Print only warnings and errors during test
config :logger, level: :warn
