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

    Logger.info("Number of workflows in query result: #{length(workflows)}")

    uploaded_workflow_ids = uploaded_workflow_ids()

    new_workflows =
      Enum.reject(workflows, &Enum.member?(uploaded_workflow_ids, Workflow.instance_id(&1)))

    Logger.info("Number of workflows that have not yet been uploaded: #{length(new_workflows)}")

    for workflow <- new_workflows do
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

  def uploaded_workflow_ids() do
    :document_viewer
    |> Application.fetch_env!(:upload_bucket)
    |> ExAws.S3.list_objects_v2(prefix: "prod/youth-pass/")
    |> ExAws.stream!()
    |> Stream.map(& &1.key)
    |> Stream.map(fn path ->
      case Regex.named_captures(~r/prod\/youth-pass\/(?<id>.+)\/.+/, path) do
        %{"id" => id} ->
          id

        _ ->
          nil
      end
    end)
    |> Stream.reject(&is_nil/1)
    |> Stream.uniq()
    |> Enum.to_list()
  end
end

# Mix.Tasks.PullSimpliGovUploads.uploaded_workflow_ids()
