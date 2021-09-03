import Config

config :document_viewer,
  api_auth_token:
    System.get_env("API_AUTH_TOKEN", Application.get_env(:document_viewer, :api_auth_token))
