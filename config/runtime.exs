import Config

if host = System.get_env("HOST") do
  config :document_viewer, DocumentViewerWeb.Endpoint, url: [host: host, port: 80]
end

if config_env() == :prod do
  config :document_viewer, DocumentViewerWeb.Endpoint,
    secret_key_base: System.get_env("SECRET_KEY_BASE")

  keycloak_opts = [
    client_id: System.fetch_env!("KEYCLOAK_CLIENT_ID"),
    client_secret: System.fetch_env!("KEYCLOAK_CLIENT_SECRET")
  ]

  config(:ueberauth_oidcc,
    issuers: [%{name: :keycloak_issuer, issuer: System.fetch_env!("KEYCLOAK_ISSUER")}],
    providers: [keycloak: keycloak_opts]
  )

  config(:ueberauth, Ueberauth,
    keycloak:
      {Ueberauth.Strategy.Oidcc,
       issuer: :keycloak_issuer, userinfo: true, uid_field: "email", scopes: ~w(openid email)}
  )
end

if guardian_secret_key = System.get_env("GUARDIAN_SECRET_KEY") do
  config :document_viewer, DocumentViewerWeb.AuthManager, secret_key: guardian_secret_key
end
