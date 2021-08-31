defmodule DocumentViewerWeb.EnsureApiAuthToken do
  @moduledoc """
  Verify that the API request includes an Authorization header with a Bearer token.
  """

  import Plug.Conn

  def init(opts) do
    Keyword.put_new(
      opts,
      :api_auth_token,
      System.get_env("API_AUTH_TOKEN", Application.get_env(:document_viewer, :api_auth_token))
    )
  end

  def call(conn, opts) do
    with {:ok, token} <- get_token(conn),
         :ok <- verify_token(token, opts) do
      conn
    else
      _ ->
        conn
        |> send_resp(:unauthorized, "Unauthorized")
        |> halt()
    end
  end

  @spec get_token(Plug.Conn.t()) :: {:ok, String.t()} | :error
  defp get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _res -> :error
    end
  end

  @spec verify_token(String.t(), keyword()) :: :ok | :error
  defp verify_token(token, api_auth_token: api_auth_token) when token == api_auth_token, do: :ok
  defp verify_token(_token, _api_auth_token), do: :error
end
