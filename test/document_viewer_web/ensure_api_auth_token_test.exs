defmodule DocumentViewerWeb.EnsureApiAuthTokenTest do
  use DocumentViewerWeb.ConnCase
  import Test.Support.Helpers

  alias DocumentViewerWeb.EnsureApiAuthToken

  @default_opts EnsureApiAuthToken.init([])

  describe "call/2" do
    @tag :with_api_token
    test "does nothing when the API token is included", %{conn: conn} do
      assert conn == EnsureApiAuthToken.call(conn, @default_opts)
    end

    test "supports multiple API tokens", %{conn: conn} do
      reassign_env(:document_viewer, :api_auth_tokens, ["123", "456"])

      conn = Plug.Conn.put_req_header(conn, "authorization", "Bearer 456")

      assert conn == EnsureApiAuthToken.call(conn, [])
    end

    test "responsd with unauthorized when the API token is not included", %{conn: conn} do
      conn = EnsureApiAuthToken.call(conn, @default_opts)

      assert response(conn, 401) == "Unauthorized"
    end
  end
end
