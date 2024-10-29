defmodule DocumentViewerWeb.AuthControllerTest do
  use DocumentViewerWeb.ConnCase
  use Plug.Test
  import ExUnit.CaptureLog
  import Test.Support.Helpers

  @mock_auth %Ueberauth.Auth{
    uid: "test@mbta.com",
    credentials: %Ueberauth.Auth.Credentials{
      expires_at: System.system_time(:second) + 1_000,
      other: %{groups: ["test-group"]}
    }
  }

  describe "GET /auth/:provider" do
    test "redirects to the callback", %{conn: conn} do
      conn = get(conn, "/auth/keycloak")
      assert redirected_to(conn) == "/auth/keycloak/callback"
    end
  end

  describe "GET /auth/:provider/callback" do
    setup do
      reassign_log_level(:info)
    end

    @tag capture_log: true
    test "redirects to the index page for an ueberauth auth", %{conn: conn} do
      conn =
        conn
        |> assign(:ueberauth_auth, @mock_auth)
        |> get("/auth/keycloak/callback")

      assert redirected_to(conn) == "/"
      assert Guardian.Plug.current_claims(conn)["groups"] == ["test-group"]
    end

    test "logs a successful login", %{conn: conn} do
      log =
        capture_log(fn ->
          conn
          |> assign(:ueberauth_auth, @mock_auth)
          |> get("/auth/keycloak/callback")
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
          |> get("/auth/keycloak/callback")
        end)

      assert log =~ "Ueberauth error: failed"
    end
  end
end
