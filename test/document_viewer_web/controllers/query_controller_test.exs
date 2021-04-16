defmodule DocumentViewerWeb.QueryControllerTest do
  use DocumentViewerWeb.ConnCase

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
    @tag :authenticated
    test "performs a search and displays the results", %{conn: conn} do
      lookup_fn = fn _, _, _ -> [] end

      conn =
        conn
        |> assign(:lookup_fn, lookup_fn)
        |> post("/", %{"query" => %{"last_name" => "Ng"}})

      assert html_response(conn, 200) =~ "Search Results"
    end

    test "unauthenticated, redirects you to cognito auth", %{conn: conn} do
      conn = post(conn, "/", %{"query" => %{"last_name" => "Ng"}})

      assert redirected_to(conn) == "/auth/cognito"
    end

    @tag :authenticated_not_in_group
    test "authenticated not in document-viewer group, redirects you to mbta.com", %{
      conn: conn
    } do
      conn = post(conn, "/", %{"query" => %{"last_name" => "Ng"}})

      assert redirected_to(conn) == "https://www.mbta.com"
    end
  end
end
