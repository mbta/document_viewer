defmodule DocumentViewerWeb.QueryControllerTest do
  use DocumentViewerWeb.ConnCase

  describe "GET /" do
    test "displays a search page", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Find Documents"
    end
  end

  describe "POST /" do
    test "performs a search and displays the results", %{conn: conn} do
      lookup_fn = fn _ -> [] end

      conn =
        conn
        |> assign(:lookup_fn, lookup_fn)
        |> post("/", %{"query" => %{"last_name" => "Ng"}})

      assert html_response(conn, 200) =~ "Search Results"
    end
  end
end
