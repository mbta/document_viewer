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
      use DocumentViewerWeb, :verified_routes

      @doc """
      Function that logs in as a user without a correct role. Ideally we could just use a
      different fake strategy but ueberauth does not provide a good way of swapping them
      out on a per test basis. So instead we are hacking in this.
      """
      def authenticated_no_valid_role(conn) do
        # This username is detected in our fake ueberauth strategy and returns a user
        # without the valid roles.
        conn = conn |> Phoenix.ConnTest.get("/auth/keycloak?user_type=no_valid_role")
        path = conn |> Phoenix.ConnTest.redirected_to()
        conn |> Phoenix.ConnTest.get(path)
      end
    end
  end

  setup tags do
    {conn, user} =
      if tags[:authenticated] do
        user = "test_user"

        conn =
          Phoenix.ConnTest.build_conn()
          |> Plug.Test.init_test_session(%{})
          |> Guardian.Plug.sign_in(DocumentViewerWeb.AuthManager, user, %{
            roles: [DocumentViewerWeb.AuthController.document_viewer_role()]
          })
          |> Plug.Conn.put_session(:username, user)

        {conn, user}
      else
        {Phoenix.ConnTest.build_conn(), nil}
      end

    {:ok, %{conn: conn, user: user}}
  end
end
