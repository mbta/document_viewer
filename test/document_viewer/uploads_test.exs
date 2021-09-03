defmodule DocumentViewer.UploadsTest do
  use ExUnit.Case, async: true

  alias DocumentViewer.Uploads

  @mock_file <<0, 255, 42>>

  describe "upload" do
    test "returns the bucket and the path if the upload is successful" do
      opts = [
        put_object_fn: fn _, _, _ -> :ok end,
        request_fn: fn _ ->
          {:ok, %{body: "", headers: [], status_code: 200}}
        end
      ]

      assert {:ok, %{bucket: _bucket, path: _path}} =
               Uploads.upload(@mock_file, "test.jpg", "pre-prod", "youth-pass", opts)
    end

    test "prepends the environment and form to the path, keeps the extension, and generates a random filename" do
      opts = [
        put_object_fn: fn _, _, _ -> :ok end,
        request_fn: fn _ ->
          {:ok, %{body: "", headers: [], status_code: 200}}
        end
      ]

      {:ok, %{path: path}} =
        Uploads.upload(@mock_file, "test.jpg", "pre-prod", "youth-pass", opts)

      assert Regex.match?(~r/^pre-prod\/youth-pass\/.+\.jpg$/, path)
    end

    test "returns an error if the upload fails" do
      opts = [
        put_object_fn: fn _, _, _ -> :ok end,
        request_fn: fn _ ->
          {:ok, %{body: "", headers: [], status_code: 500}}
        end
      ]

      assert Uploads.upload(@mock_file, "test.jpg", "pre-prod", "youth-pass", opts) == :error
    end
  end
end
