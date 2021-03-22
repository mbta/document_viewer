use Mix.Config

config :document_viewer,
  live_catalog?: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :document_viewer, DocumentViewerWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
