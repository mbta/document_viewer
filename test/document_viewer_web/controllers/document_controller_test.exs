defmodule DocumentViewerWeb.DocumentControllerTest do
  use DocumentViewerWeb.ConnCase

  describe "show: GET /documents/:bucket_name/:file_path" do
    test "displays a search page", %{conn: conn} do
      conn = get(conn, "/documents/BUCKET/FILE.pdf")

      assert html_response(conn, 200) =~ "FILE.pdf"
    end
  end

  describe "pdf: GET /documents/:bucket_name/:file_path/pdf" do
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
  end

  describe "download: GET /documents/:bucket_name/:file_path/download" do
    test "sends the document as a download" do
    end
  end
end
