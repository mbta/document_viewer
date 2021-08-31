defmodule Uploads do
  @moduledoc """
  Manages Reduced Fares uploads into S3.
  """

  @spec upload(binary(), String.t(), String.t(), String.t()) ::
          {:ok, %{bucket: String.t(), path: String.t()}} | :error
  @spec upload(binary(), String.t(), String.t(), String.t(), keyword()) ::
          {:ok, %{bucket: String.t(), path: String.t()}} | :error
  def upload(file, original_filename, environment, form, opts \\ []) do
    put_object_fn = Keyword.get(opts, :put_object_fn, &ExAws.S3.put_object/3)
    request_fn = Keyword.get(opts, :request_fn, &ExAws.stream!/1)

    with bucket <- upload_bucket(),
         path <- unique_filename(original_filename, environment, form),
         {:ok, %{status_code: 200}} <-
           bucket
           |> put_object_fn.(path, file)
           |> request_fn.() do
      {:ok, %{bucket: bucket, path: path}}
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

    "#{environment}/#{form}/#{file_uuid}.#{file_extension}"
  end
end
