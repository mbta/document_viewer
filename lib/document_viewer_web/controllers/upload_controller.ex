defmodule DocumentViewerWeb.UploadController do
  use DocumentViewerWeb, :controller

  @upload_bucket "mbta-mss-test-uploads"

  # API endpoint to get a pre-signed upload URL
  def new(conn, %{"extension" => extension}) do
    {:ok, upload_url} =
      :s3
      |> ExAws.Config.new()
      |> ExAws.S3.presigned_url(
        :put,
        @upload_bucket,
        unique_filename(extension)
      )

    json(conn, %{upload_url: upload_url})
  end

  # HTML endpoint to display an example form
  def new(conn, _params) do
    render(conn, "new.html")
  end

  @spec unique_filename(Plug.Upload.t()) :: String.t()
  defp unique_filename(extension) do
    file_uuid = UUID.uuid4(:hex)
    "#{file_uuid}.#{extension}"
  end
end
