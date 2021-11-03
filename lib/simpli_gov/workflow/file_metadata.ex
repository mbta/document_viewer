defmodule SimpliGov.Workflow.FileMetadata do
  @moduledoc """
  Metadata for an uploaded file associated with a SimpliGov workflow instance.
  """

  @type id :: String.t()

  @type t :: %__MODULE__{
          id: id(),
          name: String.t(),
          source_field_name: String.t()
        }

  @enforce_keys [:id, :name, :source_field_name]

  defstruct [
    :id,
    :name,
    :source_field_name
  ]

  @spec name(t()) :: String.t()
  def name(%__MODULE__{name: name}), do: name

  @spec s3_url_field_name(t()) :: String.t()
  def s3_url_field_name(%__MODULE__{source_field_name: source_field_name}),
    do: String.replace(source_field_name, ~r/File$/, "S3URL", global: false)

  @spec from_json({String.t(), map()}) :: t()
  def from_json({source_field_name, %{"Value" => %{"FileId" => id, "FileName" => name}}}) do
    %__MODULE__{
      id: id,
      name: name,
      source_field_name: source_field_name
    }
  end
end
