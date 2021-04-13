defmodule DocumentViewerWeb.EnsureDocumentViewerGroupTest do
  use DocumentViewerWeb.ConnCase

  alias DocumentViewerWeb.EnsureDocumentViewerGroup

  describe "init/1" do
    test "passes options through unchanged" do
      assert EnsureDocumentViewerGroup.init([]) == []
    end
  end

  describe "call/2" do
    @tag :authenticated
    test "does nothing when user is in the document-viewer group", %{conn: conn} do
      assert conn == EnsureDocumentViewerGroup.call(conn, [])
    end

    @tag :authenticated_not_in_group
    test "redirects when user is not in the document-viewer group", %{conn: conn} do
      conn = EnsureDocumentViewerGroup.call(conn, [])

      assert redirected_to(conn) == "https://www.mbta.com"
    end
  end
end
