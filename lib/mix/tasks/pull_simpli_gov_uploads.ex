defmodule Mix.Tasks.PullSimpliGovUploads do
  @moduledoc """
  Pull uploaded documents from SimpliGov, store them in S3, and save the S3 URL in SimpliGov.
  """
  use Mix.Task
  require Logger
  @requirements ["app.start"]

  alias DocumentViewer.Uploads
  alias SimpliGov.Workflow
  alias SimpliGov.Workflow.FileMetadata

  @environment "prod"
  @form "youth-pass"

  @shortdoc "Pull uploaded documents from SimpliGov and store them in S3"
  def run(_) do
    site = "https://mbta.prod.simpligov.com/prod"
    client = SimpliGov.client(site)
    workflows = SimpliGov.workflows(client)

    for workflow <- workflows do
      workflow_instance_id = Workflow.instance_id(workflow)

      Logger.info("Uploading documents for workflow: #{workflow_instance_id}")

      files_metadata = Workflow.files_metadata(workflow)

      for file_metadata <- files_metadata do
        file = SimpliGov.file(client, file_metadata)

        # Unfortunately we can't save data to SimpliGov via their API,
        # so instead we organize the uploads by workflow instance ID
        # such that they can be found manually if need be.
        {:ok, s3_url} =
          Uploads.upload(file, FileMetadata.name(file_metadata), @environment, @form,
            folder: workflow_instance_id
          )

        Logger.info("\tUploaded file: #{s3_url}")
      end
    end
  end
end
