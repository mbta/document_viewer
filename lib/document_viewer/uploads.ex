defmodule DocumentViewer.Uploads do
  @moduledoc """
  Manages Reduced Fares uploads into S3.
  """

  @spec upload(binary(), String.t(), String.t(), String.t()) ::
          {:ok, String.t()} | :error
  @spec upload(binary(), String.t(), String.t(), String.t(), keyword()) ::
          {:ok, String.t()} | :error
  def upload(file, original_filename, environment, form, opts \\ []) do
    put_object_fn = Keyword.get(opts, :put_object_fn, &ExAws.S3.put_object/3)
    request_fn = Keyword.get(opts, :request_fn, &ExAws.request!/1)

    with bucket <- upload_bucket(),
         path <- unique_filename(original_filename, environment, form),
         %{status_code: 200} <-
           bucket
           |> put_object_fn.(path, file)
           |> request_fn.() do
      {:ok, s3_url(bucket, path)}
    else
      _ -> :error
    end
  end

  @spec upload_bucket() :: String.t()
  defp upload_bucket do
    Application.fetch_env!(:document_viewer, :upload_bucket)
  end

  @spec unique_filename(String.t(), String.t(), String.t()) :: String.t()
  defp unique_filename(filename, environment, form) do
    file_extension = Path.extname(filename)
    file_uuid = UUID.uuid4(:hex)

    "#{environment}/#{form}/#{file_uuid}#{file_extension}"
  end

  @spec s3_url(String.t(), String.t()) :: String.t()
  defp s3_url(bucket, path), do: "https://#{bucket}.s3.amazonaws.com/#{path}"
end
