defmodule DocumentViewerWeb.EnsureApiAuthToken do
  @moduledoc """
  Verify that the API request includes an Authorization header with a Bearer token.
  """

  import Plug.Conn

  def init(opts), do: opts

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
  defp verify_token(token, _opts) do
    api_auth_tokens = Application.get_env(:document_viewer, :api_auth_tokens)

    Enum.reduce(api_auth_tokens, :error, fn to_compare, acc ->
      if Plug.Crypto.secure_compare(token, to_compare) do
        :ok
      else
        acc
      end
    end)
  end
end
