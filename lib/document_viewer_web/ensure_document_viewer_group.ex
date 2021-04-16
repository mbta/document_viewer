defmodule DocumentViewerWeb.EnsureDocumentViewerGroup do
  @moduledoc """
  Verify that the user is in our Cognito group.
  """

  import Plug.Conn

  def init(opts) do
    Keyword.put_new(
      opts,
      :document_viewer_group,
      Application.get_env(:document_viewer, :cognito_group)
    )
  end

  def call(conn, opts) do
    with %{"groups" => groups} <- Guardian.Plug.current_claims(conn),
         true <- is_list(groups),
         document_viewer_group = Keyword.fetch!(opts, :document_viewer_group),
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
