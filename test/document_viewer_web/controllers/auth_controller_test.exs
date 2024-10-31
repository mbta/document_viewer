defmodule DocumentViewerWeb.AuthControllerTest do
  use DocumentViewerWeb.ConnCase
  use Plug.Test
  import ExUnit.CaptureLog

  @mock_auth %Ueberauth.Auth{
    uid: "test@mbta.com",
    credentials: %Ueberauth.Auth.Credentials{
      expires_at: System.system_time(:second) + 1_000,
      other: %{roles: ["test-group"]}
    }
  }

  describe "GET /auth/:provider" do
    test "redirects to the callback", %{conn: conn} do
      conn = get(conn, ~p"/auth/keycloak")
      assert "/auth/keycloak/callback?state=" <> _state = redirected_to(conn)
    end
  end

  describe "GET /auth/:provider/callback" do
    @tag capture_log: true
    test "redirects to the index page for an ueberauth auth", %{conn: conn} do
      conn = conn |> get(~p"/auth/keycloak")

      assert "/auth/keycloak/callback?state=" <> _state = path = redirected_to(conn)

      conn = conn |> get(path)

      assert %{
               "aud" => "document_viewer",
               "exp" => _,
               "iat" => _,
               "iss" => "document_viewer",
               "jti" => _,
               "nbf" => _,
               "roles" => ["document-viewer-admin"],
               "sub" => "fake_uid",
               "typ" => "access"
             } = Guardian.Plug.current_claims(conn)
    end

    test "logs a successful login", %{conn: conn} do
      log =
        capture_log(fn ->
          conn = conn |> get(~p"/auth/keycloak")
          path = conn |> redirected_to()
          get(conn, path)
        end)

      assert log =~ "username=\"test@mbta.com\""
      assert log =~ "action=:login"
    end

    @tag capture_log: true
    test "redirects home for an ueberauth failure", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{username: "test@mbta.com"})
        |> assign(:ueberauth_failure, %Ueberauth.Failure{
          errors: [%Ueberauth.Failure.Error{message: "failed"}]
        })
        |> get("/auth/keycloak/callback")

      assert redirected_to(conn) == "https://www.mbta.com"
    end

    test "logs ueberauth failures", %{conn: conn} do
      log =
        capture_log(fn ->
          conn
          |> Plug.Test.init_test_session(%{username: "test@mbta.com"})
          |> assign(:ueberauth_failure, %Ueberauth.Failure{
            errors: [%Ueberauth.Failure.Error{message: "failed"}]
          })
          |> get(~p"/auth/keycloak/callback")
        end)

      assert log =~ "Ueberauth error: failed"
    end
  end
end
