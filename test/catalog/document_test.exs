defmodule Catalog.DocumentTest do
  use ExUnit.Case, async: true

  alias Catalog.Document

  @bucket_name "TEST_BUCKET"
  @metadata_file "TEST_METADATA_FILE_PATH"

  describe "from_metadata" do
    test "constructs a Document from a line of metadata" do
      metadata =
        "02-22-2021|MADA01234|MADA01234|DOE|JANE|05-19-1997|02-22-2021\\MADA01234_MADA01234\\987654.pdf"

      document = Document.from_metadata(metadata, @bucket_name, @metadata_file)

      assert document == %Document{
               last_name: "Doe",
               first_name: "Jane",
               date_of_birth: ~D[1997-05-19],
               scanned_date: ~D[2021-02-22],
               bucket_name: @bucket_name,
               path: "02-22-2021\\MADA01234_MADA01234\\987654.pdf",
               metadata_file: @metadata_file
             }
    end

    test "handles missing dates" do
      metadata = "|MADA01234|MADA01234|DOE|JANE||02-22-2021\\MADA01234_MADA01234\\987654.pdf"

      document = Document.from_metadata(metadata, @bucket_name, @metadata_file)

      assert document == %Document{
               last_name: "Doe",
               first_name: "Jane",
               bucket_name: @bucket_name,
               path: "02-22-2021\\MADA01234_MADA01234\\987654.pdf",
               metadata_file: @metadata_file
             }
    end
  end

  describe "key" do
    test "returns a unique key for the document" do
      document = %Document{
        last_name: "Doe",
        first_name: "Jane",
        bucket_name: @bucket_name,
        path: "02-22-2021\\MADA01234_MADA01234\\987654.pdf"
      }

      assert Document.key(document) ==
               {"TEST_BUCKET", "02-22-2021\\MADA01234_MADA01234\\987654.pdf"}
    end
  end
end
