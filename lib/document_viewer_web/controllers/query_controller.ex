defmodule DocumentViewerWeb.QueryController do
  use DocumentViewerWeb, :controller

  alias DocumentViewerWeb.Query
  alias Ecto.Changeset

  def new(conn, _params) do
    render(conn, "new.html", changeset: Query.new())
  end

  def search(conn, %{"query" => query_params}) do
    lookup_fn = Map.get(conn.assigns, :lookup_fn, &Catalog.lookup/3)

    case apply_changes(query_params) do
      {:ok, query} ->
        results = lookup_fn.(query.last_name, query.first_name, query.date_of_birth)

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
