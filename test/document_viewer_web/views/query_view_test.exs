defmodule DocumentViewerWeb.QueryViewTest do
  use DocumentViewerWeb.ConnCase, async: true

  alias Catalog.Document
  alias DocumentViewerWeb.QueryView

  doctest DocumentViewerWeb.QueryView

  describe "document_show_path" do
    test "generates a show path for a document", %{conn: conn} do
      document = %Document{
        bucket_name: "TEST_BUCKET",
        path: "TEST_FILE.pdf",
        last_name: "Doe",
        first_name: "Jane"
      }

      assert QueryView.document_show_path(conn, document) ==
               "/documents/TEST_BUCKET/TEST_FILE.pdf"
    end
  end
end
