defmodule DocumentViewerWeb.EnsureDocumentViewerGroupTest do
  use DocumentViewerWeb.ConnCase

  alias DocumentViewerWeb.EnsureDocumentViewerGroup

  @default_opts EnsureDocumentViewerGroup.init([])

  describe "init/1" do
    test "passes options through with the addition of the cognito group" do
      assert EnsureDocumentViewerGroup.init([]) == [document_viewer_group: "document-viewer"]
    end
  end

  describe "call/2" do
    @tag :authenticated
    test "does nothing when user is in the document-viewer group", %{conn: conn} do
      assert conn == EnsureDocumentViewerGroup.call(conn, @default_opts)
    end

    @tag :authenticated_not_in_group
    test "redirects when user is not in the document-viewer group", %{conn: conn} do
      conn = EnsureDocumentViewerGroup.call(conn, @default_opts)

      assert redirected_to(conn) == "https://www.mbta.com"
    end
  end
end
