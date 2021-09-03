import Config

if token = System.get_env("API_AUTH_TOKEN") do
  config :document_viewer,
    api_auth_token: token
end
