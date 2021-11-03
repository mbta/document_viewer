defmodule SimpliGov.Workflow do
  @moduledoc """
  A SimpliGov Youth Pass workflow instance.
  This is the SimpliGov data representing an individual Youth Pass application.
  """

  alias SimpliGov.Workflow.FileMetadata

  @type id :: String.t()

  @type t :: %__MODULE__{
          instance_id: id(),
          files_metadata: [FileMetadata.t()]
        }

  @enforce_keys [:instance_id]

  defstruct [
    :instance_id,
    files_metadata: []
  ]

  @spec instance_id(t()) :: id()
  def instance_id(%__MODULE__{instance_id: instance_id}), do: instance_id

  @spec files_metadata(t()) :: [FileMetadata.t()]
  def files_metadata(%__MODULE__{files_metadata: files_metadata}), do: files_metadata

  @spec from_json(map()) :: t()
  def from_json(%{"WorkflowInstanceId" => instance_id, "Fields" => fields}) do
    %__MODULE__{
      instance_id: instance_id,
      files_metadata: file_metadata_from_fields(fields)
    }
  end

  defp file_metadata_from_fields(all_fields) do
    all_fields
    |> Enum.filter(&file_field?/1)
    |> Enum.map(&FileMetadata.from_json/1)
  end

  defp file_field?({_key, %{"Value" => %{"FileId" => _file_id, "FileName" => _file_name}}}),
    do: true

  defp file_field?({_key, _val}), do: false
end
