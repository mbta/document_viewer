defmodule DocumentViewerWeb.QueryView do
  use DocumentViewerWeb, :view

  alias Catalog.Document

  @doc """
  Generate a show path for a specific document
  """
  @spec document_show_path(Plug.Conn.t(), Document.t()) :: String.t()
  def document_show_path(conn, document) do
    {bucket_name, file_path} = Document.key(document)
    Routes.document_path(conn, :show, bucket_name, file_path)
  end

  @doc """
  Formats an date in US style.any()

  iex> DocumentViewerWeb.QueryView.format_date(~D[1974-02-22])
  "2/22/1974"
  iex> DocumentViewerWeb.QueryView.format_date(nil)
  "unknown"
  """
  @spec format_date(Date.t()) :: String.t()
  def format_date(nil), do: "unknown"
  def format_date(date), do: "#{date.month}/#{date.day}/#{date.year}"
end
