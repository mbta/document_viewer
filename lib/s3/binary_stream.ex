defmodule S3.BinaryStream do
  @moduledoc """
  Provide an S3 object as a stream of binary chunks.
  """

  @doc """
  Returns an S3 object as a stream of binary chunks.
  """
  @spec binary_chunks(String.t(), String.t()) :: Enumerable.t()
  @spec binary_chunks(String.t(), String.t(), ExAws.S3.download_file_opts()) :: Enumerable.t()
  def binary_chunks(bucket, file, opts \\ []) do
    bucket
    |> ExAws.S3.download_file(file, :memory, opts)
    |> ExAws.stream!()
  end
end
