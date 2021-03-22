defmodule Catalog.BucketTest do
  use ExUnit.Case, async: true

  alias Catalog.Bucket

  @bucket %Bucket{
    name: "TEST_BUCKET",
    excluded_files: ["TEST.txt"]
  }

  describe "metadata_files" do
    test "retrieves a list of metadata file paths across all buckets" do
      opts = [
        list_objects_fn: fn _, _ -> :ok end,
        stream_fn: fn _ ->
          [
            %{key: "a1.txt"},
            %{key: "dir1/a2.txt"}
          ]
        end
      ]

      assert Bucket.metadata_files(@bucket, opts) ==
               {"TEST_BUCKET", ["a1.txt", "dir1/a2.txt"]}
    end

    test "excludes files with an extension other than '.txt'" do
      opts = [
        list_objects_fn: fn _, _ -> :ok end,
        stream_fn: fn _ ->
          [
            %{key: "a1.txt"},
            %{key: "dir1/a2.txt"},
            %{key: "bad1.pdf"},
            %{key: "bad2.tif"}
          ]
        end
      ]

      assert Bucket.metadata_files(@bucket, opts) ==
               {"TEST_BUCKET", ["a1.txt", "dir1/a2.txt"]}
    end

    test "excludes excluded files specified by the bucket configuration" do
      opts = [
        list_objects_fn: fn _, _ -> :ok end,
        stream_fn: fn _ ->
          [
            %{key: "a1.txt"},
            %{key: "dir1/a2.txt"},
            %{key: "TEST.txt"}
          ]
        end
      ]

      assert Bucket.metadata_files(@bucket, opts) ==
               {"TEST_BUCKET", ["a1.txt", "dir1/a2.txt"]}
    end
  end
end
