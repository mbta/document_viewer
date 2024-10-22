import Config

if host = System.get_env("HOST") do
  config :document_viewer, DocumentViewerWeb.Endpoint, url: [host: host, port: 80]
end

config :document_viewer, DocumentViewerWeb.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

if guardian_secret_key = System.get_env("GUARDIAN_SECRET_KEY") do
  config :document_viewer, DocumentViewerWeb.AuthManager, secret_key: guardian_secret_key
end

config :ueberauth, Ueberauth.Strategy.Cognito,
  auth_domain: System.get_env("COGNITO_DOMAIN"),
  client_id: System.get_env("COGNITO_CLIENT_ID"),
  client_secret: System.get_env("COGNITO_CLIENT_SECRET"),
  user_pool_id: System.get_env("COGNITO_USER_POOL_ID"),
  aws_region: System.get_env("COGNITO_AWS_REGION")

if config_env() == :dev do
  config(:document_viewer, live_catalog?: false)

  config(:document_viewer, DocumentViewerWeb.Endpoint,
    http: [port: 4000],
    secret_key_base: "GQz2AbfSliQp6FYTncpcZJgM7skJdhKH6refgghsdE9gOz0TQ5u5+Er+tzH6XmUt",
    debug_errors: true,
    live_catalog?: false,
    code_reloader: true,
    check_origin: false,
    watchers: [
      node: [
        "node_modules/webpack/bin/webpack.js",
        "--mode",
        "development",
        "--watch-stdin",
        cd: Path.expand("../assets", __DIR__)
      ]
    ]
  )
end

if config_env() == :test do
  config :document_viewer, DocumentViewerWeb.Endpoint,
    http: [port: 4002],
    secret_key_base: "GQz2AbfSliQp6FYTncpcZJgM7skJdhKH6refgghsdE9gOz0TQ5u5+Er+tzH6XmUt",
    server: false
end
