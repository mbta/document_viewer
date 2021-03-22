defmodule Catalog.Bucket do
  @moduledoc """
  Configuration representing an S3 bucket.

  The excluded_files property is a list of a files we do not want to catalog for document listings.
  """
  alias Catalog.Document

  @type name :: String.t()

  @type t :: %__MODULE__{
          name: name(),
          excluded_files: [Document.file_path()]
        }

  @enforce_keys [:name, :excluded_files]

  defstruct [
    :name,
    excluded_files: []
  ]

  @doc """
  Return a list of metadata file paths for this bucket.

  Metadata files start with the prefix "MADA" and use the extension ".txt".

  Does not include any files in the Bucket's excluded_files list.
  """
  @spec metadata_files(t()) :: {name(), [Document.file_path()]}
  @spec metadata_files(t(), keyword()) :: {name(), [Document.file_path()]}
  def metadata_files(%{name: name, excluded_files: excluded_files}, opts \\ []) do
    list_objects_fn = Keyword.get(opts, :list_objects_fn, &ExAws.S3.list_objects_v2/2)
    stream_fn = Keyword.get(opts, :stream_fn, &ExAws.stream!/1)

    files =
      name
      |> list_objects_fn.(prefix: "MADA")
      |> stream_fn.()
      |> Stream.map(& &1.key)
      |> Stream.filter(fn path -> Path.extname(path) == ".txt" and path not in excluded_files end)
      |> Enum.to_list()

    {name, files}
  end
end
