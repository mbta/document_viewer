defmodule SimpliGov.WorkflowTest do
  use ExUnit.Case, async: true

  alias SimpliGov.Workflow
  alias SimpliGov.Workflow.FileMetadata

  @workflow_json %{
    "AssigneeName" => "",
    "Fields" => %{
      "NonFileField" => %{
        "DataTypeDescriptor" => "t",
        "Label" => "Group Admin User Three",
        "StructureTypeDescriptor" => "p",
        "Value" => "jeremy.kazanjianamory@boston.gov"
      },
      "ProofOfAgeFile" => %{
        "Value" => %{
          "FileId" => "725AC6F2-3F8A-481D-802B-08490F1E5D43",
          "FileName" => "image.jpg"
        }
      },
      "ProofOfEligibilityFile" => %{
        "DataTypeDescriptor" => "g",
        "Label" => "Upload a .gif, .jpeg, .jpg, .pdf, or .png file (required)",
        "StructureTypeDescriptor" => "f",
        "Value" => %{
          "FileId" => "09D217F8-B2B0-46F9-B61F-08FDE656F7B7",
          "FileName" => "image.jpg"
        }
      },
      "ProofOfResidencyFile" => %{
        "DataTypeDescriptor" => "g",
        "Label" => "Upload a .gif, .jpeg, .jpg, .pdf, or .png file (required)",
        "StructureTypeDescriptor" => "f",
        "Value" => %{
          "FileId" => "32D54147-854D-4D66-9B15-35DCB7FE3DE0",
          "FileName" => "image.jpg"
        }
      }
    },
    # Files listed in the "FilesMetadata" seem to have an incorrect "FileID" and should not be used
    "FilesMetadata" => [
      %{
        "DocumentName" => nil,
        "ESignatureStatus" => nil,
        "FileId" => "775ace7f-8660-44f8-bfa3-05c9776b6be6",
        "FileName" => "image.jpg",
        "Signed" => nil,
        "Source" => "formsubmit",
        "SourceFieldLabel" => "Upload a .gif, .jpeg, .jpg, .pdf, or .png file  (required)",
        "SourceFieldName" => "ProofOfAgeFile",
        "Version" => 1
      },
      %{
        "DocumentName" => nil,
        "ESignatureStatus" => nil,
        "FileId" => "83861488-0856-44ac-bca9-0ce1d2f2af08",
        "FileName" => "image.jpg",
        "Signed" => nil,
        "Source" => "formsubmit",
        "SourceFieldLabel" => "Upload a .gif, .jpeg, .jpg, .pdf, or .png file (required)",
        "SourceFieldName" => "ProofOfResidencyFile",
        "Version" => 1
      },
      %{
        "DocumentName" => nil,
        "ESignatureStatus" => nil,
        "FileId" => "f93f0328-ac13-4750-9058-9d4b98d3a13b",
        "FileName" => "image.jpg",
        "Signed" => nil,
        "Source" => "formsubmit",
        "SourceFieldLabel" => "Upload a .gif, .jpeg, .jpg, .pdf, or .png file (required)",
        "SourceFieldName" => "ProofOfEligibilityFile",
        "Version" => 1
      }
    ],
    "RequesterEmail" => "TEST@example.com",
    "RequesterName" => "TEST@example.com",
    "WorkflowInstanceCompleted" => "2021-11-04T17:14:20",
    "WorkflowInstanceCreated" => "2021-11-04T17:11:36",
    "WorkflowInstanceId" => "e491a0eb-8ab8-4b09-a52b-07cddebc0838"
  }

  describe "instance_id/1" do
    test "returns the instance_id for the given workflow instance" do
      workflow = %Workflow{
        instance_id: "TEST_WORKFLOW_ID"
      }

      assert Workflow.instance_id(workflow) == "TEST_WORKFLOW_ID"
    end
  end

  describe "files_metadata/1" do
    test "returns the list of file metadata for this workflow instance" do
      files_metadata = [
        %FileMetadata{
          id: "TEST_FILE_ID",
          name: "TEST_FILE_NAME",
          source_field_name: "TEST_SOURCE_FIELD_NAME"
        }
      ]

      workflow = %Workflow{
        instance_id: "TEST_WORKFLOW_ID",
        files_metadata: files_metadata
      }

      assert Workflow.files_metadata(workflow) == files_metadata
    end
  end

  describe "from_json/1" do
    test "convert json data into a Workflow struct" do
      assert %Workflow{
               instance_id: "e491a0eb-8ab8-4b09-a52b-07cddebc0838",
               files_metadata: _files_metadata
             } = Workflow.from_json(@workflow_json)
    end

    test "parses the list of file metadata including the correct file IDs" do
      %Workflow{
        files_metadata: [
          %FileMetadata{id: "725AC6F2-3F8A-481D-802B-08490F1E5D43"},
          %FileMetadata{id: "09D217F8-B2B0-46F9-B61F-08FDE656F7B7"},
          %FileMetadata{id: "32D54147-854D-4D66-9B15-35DCB7FE3DE0"}
        ]
      } = Workflow.from_json(@workflow_json)
    end
  end
end
