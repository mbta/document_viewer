defmodule DocumentViewerWeb.DocumentController do
  use DocumentViewerWeb, :controller

  def show(conn, %{"bucket_name" => bucket_name, "file_path" => file_path}) do
    config_fn = Map.get(conn.assigns, :config_fn, &ExAws.Config.new/1)
    presigned_url_fn = Map.get(conn.assigns, :presigned_url_fn, &ExAws.S3.presigned_url/4)
    url = presigned_url(bucket_name, file_path, config_fn, presigned_url_fn)

    redirect(conn, external: url)
  end

  @spec presigned_url(String.t(), String.t(), function(), function()) :: String.t()
  defp presigned_url(bucket_name, file_path, config_fn, presigned_url_fn) do
    {:ok, url} =
      :s3
      |> config_fn.()
      |> presigned_url_fn.(:get, bucket_name, file_path)

    url
  end
end
