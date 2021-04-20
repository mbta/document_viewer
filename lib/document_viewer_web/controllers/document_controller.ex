defmodule DocumentViewerWeb.DocumentController do
  use DocumentViewerWeb, :controller

  alias DocumentViewerWeb.UserActionLogger

  def show(conn, %{"bucket_name" => bucket_name, "file_path" => file_path} = params) do
    UserActionLogger.log(get_session(conn, "username"), :view_document, params)

    conn
    |> assign(:bucket_name, bucket_name)
    |> assign(:file_path, file_path)
    |> render("show.html")
  end

  def pdf(
        conn,
        %{"bucket_name" => bucket_name, "file_path" => file_path} = params
      ) do
    config_fn = Map.get(conn.assigns, :config_fn, &ExAws.Config.new/1)
    presigned_url_fn = Map.get(conn.assigns, :presigned_url_fn, &ExAws.S3.presigned_url/5)

    file_name = Path.basename(file_path)

    log_download(conn, params)

    url =
      presigned_url(bucket_name, file_path, config_fn, presigned_url_fn,
        query_params: query_params(file_name, params)
      )

    redirect(conn, external: url)
  end

  defp log_download(conn, %{"download" => "true"} = params),
    do: UserActionLogger.log(get_session(conn, "username"), :download_document, params)

  defp log_download(_, _), do: :ok

  defp query_params(file_name, %{"download" => "true"}),
    do: ["response-content-disposition": "attachment; filename=\"#{file_name}\""]

  defp query_params(file_name, _),
    do: ["response-content-disposition": "inline; filename=\"#{file_name}\""]

  @spec presigned_url(String.t(), String.t(), function(), function(), keyword()) :: String.t()
  defp presigned_url(bucket_name, file_path, config_fn, presigned_url_fn, opts) do
    {:ok, url} =
      :s3
      |> config_fn.()
      |> presigned_url_fn.(:get, bucket_name, file_path, opts)

    url
  end
end
