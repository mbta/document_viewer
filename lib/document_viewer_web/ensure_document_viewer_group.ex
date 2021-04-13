defmodule DocumentViewerWeb.EnsureDocumentViewerGroup do
  @moduledoc """
  Verify that the user is in our Cognito group.
  """

  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    with %{"groups" => groups} <- Guardian.Plug.current_claims(conn),
         true <- is_list(groups),
         document_viewer_group <- Application.get_env(:document_viewer, :cognito_group),
         true <- document_viewer_group in groups do
      conn
    else
      _ ->
        conn
        |> Phoenix.Controller.redirect(external: "https://www.mbta.com")
        |> halt()
    end
  end
end
