defmodule DocumentViewerWeb.QueryView do
  use DocumentViewerWeb, :view

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
