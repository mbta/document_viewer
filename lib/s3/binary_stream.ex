defmodule S3.BinaryStream do
  @moduledoc """
  Provide an S3 object as a stream of binary chunks.
  """

  @doc """
  Returns an S3 object as a stream of binary chunks.
  """
  @spec binary_chunks(String.t(), String.t(), ExAws.S3.download_file_opts()) :: Enumerable.t()
  def binary_chunks(bucket, file, opts \\ []) do
    download_file_fn = Keyword.get(opts, :download_file_fn, &ExAws.S3.download_file/4)
    stream_fn = Keyword.get(opts, :stream_fn, &ExAws.stream!/1)

    bucket
    |> download_file_fn.(file, :memory, opts)
    |> stream_fn.()
  end
end
