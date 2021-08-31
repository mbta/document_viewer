use Mix.Config

config :document_viewer,
  live_catalog?: false,
  api_auth_token: "TEST_TOKEN"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :document_viewer, DocumentViewerWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "GQz2AbfSliQp6FYTncpcZJgM7skJdhKH6refgghsdE9gOz0TQ5u5+Er+tzH6XmUt",
  server: false

config :document_viewer, DocumentViewerWeb.AuthManager, secret_key: "test key"

# Print only warnings and errors during test
config :logger, level: :warn
