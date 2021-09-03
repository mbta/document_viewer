defmodule DocumentViewerWeb.EnsureApiAuthTokenTest do
  use DocumentViewerWeb.ConnCase

  alias DocumentViewerWeb.EnsureApiAuthToken

  @default_opts EnsureApiAuthToken.init([])

  describe "init/1" do
    test "passes options through with the addition of the api auth token" do
      assert [api_auth_token: _] = EnsureApiAuthToken.init([])
    end
  end

  describe "call/2" do
    @tag :with_api_token
    test "does nothing when the API token is included", %{conn: conn} do
      assert conn == EnsureApiAuthToken.call(conn, @default_opts)
    end

    test "responsd with unauthorized when the API token is not included", %{conn: conn} do
      conn = EnsureApiAuthToken.call(conn, @default_opts)

      assert response(conn, 401) == "Unauthorized"
    end
  end
end
