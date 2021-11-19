defmodule DocumentViewer.UploadsTest do
  use ExUnit.Case, async: true

  alias DocumentViewer.Uploads

  @mock_file <<0, 255, 42>>

  describe "upload" do
    test "returns an S3 URL if the upload is successful" do
      opts = [
        put_object_fn: fn _, _, _ -> :ok end,
        request_fn: fn _ ->
          %{body: "", headers: [], status_code: 200}
        end
      ]

      assert {:ok, url} = Uploads.upload(@mock_file, "test.jpg", "preprod", "youth-pass", opts)

      assert url =~ ~r/https:\/\/#{upload_bucket()}\.s3\.amazonaws\.com\/.+/
    end

    test "prepends the environment and form to the path, keeps the extension, and generates a random filename" do
      opts = [
        put_object_fn: fn _, _, _ -> :ok end,
        request_fn: fn _ ->
          %{body: "", headers: [], status_code: 200}
        end
      ]

      {:ok, url} = Uploads.upload(@mock_file, "test.jpg", "preprod", "youth-pass", opts)

      assert url =~ ~r/preprod\/youth-pass\/[0-9a-f]+\.jpg$/
    end

    test "returns an error if the upload fails" do
      opts = [
        put_object_fn: fn _, _, _ -> :ok end,
        request_fn: fn _ ->
          %{body: "", headers: [], status_code: 500}
        end
      ]

      assert Uploads.upload(@mock_file, "test.jpg", "preprod", "youth-pass", opts) == :error
    end
  end

  defp upload_bucket, do: Application.fetch_env!(:document_viewer, :upload_bucket)
end
