import Config

if token = System.get_env("API_AUTH_TOKENS") do
  config :document_viewer,
    api_auth_tokens: token
end
