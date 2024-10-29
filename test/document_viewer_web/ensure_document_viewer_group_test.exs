defmodule DocumentViewerWeb.EnsureDocumentViewerRoleTest do
  use DocumentViewerWeb.ConnCase

  alias DocumentViewerWeb.EnsureDocumentViewerRole

  @default_opts EnsureDocumentViewerRole.init([])

  describe "init/1" do
    test "passes options through with the addition of the cognito group" do
      assert EnsureDocumentViewerRole.init([]) == [document_viewer_group: "document-viewer"]
    end
  end

  describe "call/2" do
    @tag :authenticated
    test "does nothing when user is in the document-viewer group", %{conn: conn} do
      assert conn == EnsureDocumentViewerRole.call(conn, @default_opts)
    end

    @tag :authenticated_not_in_group
    test "redirects when user is not in the document-viewer group", %{conn: conn} do
      conn = EnsureDocumentViewerRole.call(conn, @default_opts)

      assert redirected_to(conn) == "https://www.mbta.com"
    end
  end
end
