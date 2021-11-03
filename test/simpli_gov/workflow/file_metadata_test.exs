defmodule SimpliGov.Workflow.FileMetadataTest do
  use ExUnit.Case, async: true

  alias SimpliGov.Workflow.FileMetadata

  describe "name" do
    test "returns the name for this file" do
      file_metadata = %FileMetadata{
        id: "TEST_FILE_ID",
        name: "TEST_FILE_NAME",
        source_field_name: "TEST_SOURCE_FIELD_NAME"
      }

      assert FileMetadata.name(file_metadata) == "TEST_FILE_NAME"
    end
  end

  describe "s3_url_field_name" do
    test "returns the expected S3 URL field name determined based on the source field name for this file" do
      file_metadata = %FileMetadata{
        id: "TEST_FILE_ID",
        name: "TEST_FILE_NAME",
        source_field_name: "ProofOfEligibilityFile"
      }

      assert FileMetadata.s3_url_field_name(file_metadata) == "ProofOfEligibilityS3URL"
    end
  end

  describe "from_json" do
    test "convert json data into a FileMetadata struct" do
      assert FileMetadata.from_json(
               {"ProofOfAgeFile",
                %{
                  "Value" => %{
                    "FileId" => "TEST_ID",
                    "FileName" => "TEST_NAME.jpg"
                  }
                }}
             ) == %FileMetadata{
               id: "TEST_ID",
               name: "TEST_NAME.jpg",
               source_field_name: "ProofOfAgeFile"
             }
    end
  end
end
