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
  config(:document_viewer, DocumentViewerWeb.Endpoint,
    secret_key_base: "GQz2AbfSliQp6FYTncpcZJgM7skJdhKH6refgghsdE9gOz0TQ5u5+Er+tzH6XmUt"
  )
end

if config_env() == :test do
  config :document_viewer, DocumentViewerWeb.Endpoint,
    secret_key_base: "GQz2AbfSliQp6FYTncpcZJgM7skJdhKH6refgghsdE9gOz0TQ5u5+Er+tzH6XmUt"
end
