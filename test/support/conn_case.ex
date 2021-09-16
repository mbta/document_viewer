defmodule DocumentViewerWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use DocumentViewerWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import DocumentViewerWeb.ConnCase

      alias DocumentViewerWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint DocumentViewerWeb.Endpoint
    end
  end

  setup tags do
    {conn, user} =
      cond do
        tags[:authenticated] ->
          user = "test_user"
          document_viewer_group = Application.get_env(:document_viewer, :cognito_group)

          conn =
            Phoenix.ConnTest.build_conn()
            |> Plug.Test.init_test_session(%{})
            |> Guardian.Plug.sign_in(DocumentViewerWeb.AuthManager, user, %{
              groups: [document_viewer_group]
            })
            |> Plug.Conn.put_session(:username, user)

          {conn, user}

        tags[:authenticated_not_in_group] ->
          user = "test_user"

          conn =
            Phoenix.ConnTest.build_conn()
            |> Plug.Test.init_test_session(%{})
            |> Guardian.Plug.sign_in(DocumentViewerWeb.AuthManager, user, %{groups: []})
            |> Plug.Conn.put_session(:username, user)

          {conn, user}

        tags[:with_api_token] ->
          api_auth_tokens = Application.get_env(:document_viewer, :api_auth_tokens)

          conn =
            Phoenix.ConnTest.build_conn()
            |> Plug.Test.init_test_session(%{})
            |> Plug.Conn.put_req_header("authorization", "Bearer #{api_auth_tokens}")

          {conn, nil}

        true ->
          {Phoenix.ConnTest.build_conn(), nil}
      end

    {:ok, %{conn: conn, user: user}}
  end
end
