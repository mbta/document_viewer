defmodule DocumentViewerWeb.DocumentControllerTest do
  use DocumentViewerWeb.ConnCase
  import ExUnit.CaptureLog
  import Test.Support.Helpers

  @moduletag capture_log: true

  describe "show: GET /documents/:bucket_name/:file_path" do
    setup do
      reassign_log_level(:info)
    end

    @tag :authenticated
    test "displays a search page", %{conn: conn} do
      conn = get(conn, "/documents/BUCKET/FILE.pdf")

      assert html_response(conn, 200) =~ "FILE.pdf"
    end

    @tag :authenticated
    test "logs that the user viewed the document", %{conn: conn} do
      log =
        capture_log(fn ->
          get(conn, "/documents/BUCKET/FILE.pdf")
        end)

      assert log =~ "test_user"
      assert log =~ "action=view_document"
      assert log =~ "bucket_name=BUCKET"
      assert log =~ "file_path=FILE.pdf"
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
    setup do
      reassign_log_level(:info)
    end

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

    @tag :authenticated
    test "download requested, logs that the user downloaded the document", %{conn: conn} do
      config_fn = fn _ -> %{} end

      presigned_url_fn = fn _, _, _, _, _ ->
        {:ok, "https://example.com/BUCKET/FILE.pdf"}
      end

      log =
        capture_log(fn ->
          conn
          |> assign(:config_fn, config_fn)
          |> assign(:presigned_url_fn, presigned_url_fn)
          |> get("/documents/BUCKET/FILE.pdf/pdf?download=true")
        end)

      assert log =~ "test_user"
      assert log =~ "action=download_document"
      assert log =~ "bucket_name=BUCKET"
      assert log =~ "file_path=FILE.pdf"
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
