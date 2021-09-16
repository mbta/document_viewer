import Config

if tokens_str = System.get_env("API_AUTH_TOKENS") do
  tokens = String.split(tokens_str, ",")

  config :document_viewer,
    api_auth_tokens: tokens
end
