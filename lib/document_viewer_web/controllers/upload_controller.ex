defmodule DocumentViewerWeb.UploadController do
  use DocumentViewerWeb, :controller

  @upload_bucket "mbta-mss-test-uploads"

  def new(conn, _params) do
    conn
    |> assign_csrf_token()
    |> render("new.html")
  end

  def create(conn, %{"file" => file}) do
    {:ok, file_binary} = File.read(file.path)

    {:ok, _} =
      @upload_bucket
      |> ExAws.S3.put_object(unique_filename(file), file_binary)
      |> ExAws.request()

    conn
    |> put_flash(:success, "File uploaded successfully!")
    |> assign_csrf_token()
    |> render("new.html")
  end

  @spec unique_filename(Plug.Upload.t()) :: String.t()
  defp unique_filename(%Plug.Upload{filename: filename}) do
    file_extension = Path.extname(filename)
    file_uuid = UUID.uuid4(:hex)

    "#{file_uuid}.#{file_extension}"
  end

  defp assign_csrf_token(conn),
    do: assign(conn, :csrf_token, Plug.CSRFProtection.get_csrf_token())
end
