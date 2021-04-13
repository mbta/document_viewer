defmodule DocumentViewerWeb.DocumentControllerTest do
  use DocumentViewerWeb.ConnCase

  describe "show: GET /documents/:bucket_name/:file_path" do
    @tag :authenticated
    test "displays a search page", %{conn: conn} do
      conn = get(conn, "/documents/BUCKET/FILE.pdf")

      assert html_response(conn, 200) =~ "FILE.pdf"
    end

    test "unauthenticated, redirects you to cognito auth", %{conn: conn} do
      conn = get(conn, "/documents/BUCKET/FILE.pdf")

      assert redirected_to(conn) == "/auth/cognito"
    end

    @tag :authenticated_not_in_group
    test "authenticated not in document-viewer group, redirects you to mbta.com", %{
      conn: conn
    } do
      conn = get(conn, "/documents/BUCKET/FILE.pdf")

      assert redirected_to(conn) == "https://www.mbta.com"
    end
  end

  describe "pdf: GET /documents/:bucket_name/:file_path/pdf" do
    @tag :authenticated
    test "redirects you to the desired document", %{conn: conn} do
      redirect_url = "https://example.com/BUCKET/FILE.pdf"

      config_fn = fn _ -> %{} end

      presigned_url_fn = fn _, _, _, _, _ ->
        {:ok, redirect_url}
      end

      conn =
        conn
        |> assign(:config_fn, config_fn)
        |> assign(:presigned_url_fn, presigned_url_fn)
        |> get("/documents/BUCKET/FILE.pdf/pdf")

      assert redirected_to(conn) == redirect_url
    end

    test "unauthenticated, redirects you to cognito auth", %{conn: conn} do
      conn = get(conn, "/documents/BUCKET/FILE.pdf/pdf")

      assert redirected_to(conn) == "/auth/cognito"
    end

    @tag :authenticated_not_in_group
    test "authenticated not in document-viewer group, redirects you to mbta.com", %{
      conn: conn
    } do
      conn = get(conn, "/documents/BUCKET/FILE.pdf/pdf")

      assert redirected_to(conn) == "https://www.mbta.com"
    end
  end
end
