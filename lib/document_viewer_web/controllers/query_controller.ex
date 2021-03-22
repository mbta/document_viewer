defmodule DocumentViewerWeb.QueryController do
  use DocumentViewerWeb, :controller

  alias Catalog.Query
  alias Ecto.Changeset

  def new(conn, _params) do
    render(conn, "new.html", changeset: Query.new())
  end

  def search(conn, %{"query" => query_params}) do
    lookup_fn = Map.get(conn.assigns, :lookup_fn, &Catalog.lookup/1)

    case apply_changes(query_params) do
      {:ok, query} ->
        results = lookup_fn.(query)

        conn
        |> assign(:results, results)
        |> render("search.html")

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp apply_changes(params) do
    %Query{}
    |> Query.changeset(params)
    |> Changeset.apply_action(:search)
  end
end
