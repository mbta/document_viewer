defmodule DocumentViewerWeb.AuthControllerTest do
  # This is not async because we change the logger level in here which could lead to
  # flaky tests elsewhere.
  use DocumentViewerWeb.ConnCase, async: false
  use Plug.Test
  import ExUnit.CaptureLog

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
      Logger.configure(level: :info)

      log =
        capture_log(fn ->
          conn = conn |> get(~p"/auth/keycloak")
          assert "/auth/keycloak/callback?state=" <> _state = path = redirected_to(conn)
          get(conn, path)
        end)

      assert log =~ "User action: action=:login, username=\"fake_uid\""
      Logger.configure(level: :warning)
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
          conn |> get(~p"/auth/keycloak/callback")
        end)

      assert log =~ "Ueberauth error: Cross-Site Request Forgery attack"
    end
  end
end
