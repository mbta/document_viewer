defmodule DocumentViewerWeb.UploadController do
  use DocumentViewerWeb, :controller

  alias DocumentViewer.Uploads

  def create(conn, %{
        "file" => file = %Plug.Upload{filename: filename},
        "environment" => environment,
        "form" => form
      }) do
    upload_fn = Map.get(conn.assigns, :upload_fn, &Uploads.upload/4)

    {:ok, file_binary} = File.read(file.path)

    {:ok, s3_url} = upload_fn.(file_binary, filename, environment, form)

    json(conn, %{s3_url: s3_url})
  end

  def create(conn, _) do
    conn
    |> put_status(400)
    |> json(%{message: "Bad request"})
  end
end
