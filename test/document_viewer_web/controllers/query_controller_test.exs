defmodule DocumentViewerWeb.QueryControllerTest do
  use DocumentViewerWeb.ConnCase
  import ExUnit.CaptureLog
  import Test.Support.Helpers

  describe "GET /" do
    @tag :authenticated
    test "displays a search page", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Find Documents"
    end

    test "unauthenticated, redirects you to cognito auth", %{conn: conn} do
      conn = get(conn, "/")

      assert redirected_to(conn) == "/auth/cognito"
    end

    @tag :authenticated_not_in_group
    test "authenticated not in document-viewer group, redirects you to mbta.com", %{
      conn: conn
    } do
      conn = get(conn, "/")

      assert redirected_to(conn) == "https://www.mbta.com"
    end
  end

  describe "POST /" do
    setup do
      reassign_log_level(:info)
    end

    @tag :authenticated
    @tag capture_log: true
    test "performs a search and displays the results", %{conn: conn} do
      lookup_fn = fn _, _, _ -> [] end

      conn =
        conn
        |> assign(:lookup_fn, lookup_fn)
        |> post("/", %{"query" => %{"last_name" => "Ng"}})

      assert html_response(conn, 200) =~ "Search Results"
    end

    @tag :authenticated
    test "logs the search", %{conn: conn} do
      lookup_fn = fn _, _, _ -> [] end

      log =
        capture_log(fn ->
          conn
          |> assign(:lookup_fn, lookup_fn)
          |> post("/", %{
            "query" => %{
              "last_name" => "Ng",
              "first_name" => "Mary",
              "date_of_birth_string" => "1/1/1970"
            }
          })
        end)

      assert log =~ "username=\"test_user\""
      assert log =~ "action=:search"
      assert log =~ "last_name=\"Ng\""
      assert log =~ "first_name=\"Mary\""
      assert log =~ "date_of_birth_string=\"1/1/1970\""
    end

    @tag capture_log: true
    test "unauthenticated, redirects you to cognito auth", %{conn: conn} do
      conn = post(conn, "/", %{"query" => %{"last_name" => "Ng"}})

      assert redirected_to(conn) == "/auth/cognito"
    end

    @tag :authenticated_not_in_group
    @tag capture_log: true
    test "authenticated not in document-viewer group, redirects you to mbta.com", %{
      conn: conn
    } do
      conn = post(conn, "/", %{"query" => %{"last_name" => "Ng"}})

      assert redirected_to(conn) == "https://www.mbta.com"
    end
  end
end
