defmodule DocumentViewerWeb.EnsureApiAuthToken do
  @moduledoc """
  Verify that the API request includes an Authorization header with a Bearer token.
  """

  import Plug.Conn

  def init(opts) do
    Keyword.put_new(
      opts,
      :api_auth_token,
      Application.get_env(:document_viewer, :api_auth_token)
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
  defp verify_token(token, opts) do
    api_auth_token = Keyword.get(opts, :api_auth_token)

    if Plug.Crypto.secure_compare(token, api_auth_token) do
      :ok
    else
      :error
    end
  end
end
