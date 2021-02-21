defmodule S3.ObjectStream do
  @moduledoc """
  Provide an S3 object as a line-by-line stream.
  """

  @doc """
  Returns a stream of lines for a text file in an S3 bucket. Each element of
  the stream will be a single line instead of a binary chunk.
  """
  @spec lines(binary(), binary(), ExAws.S3.download_file_opts()) :: Enumerable.t()
  def lines(bucket, file, opts \\ []) do
    bucket
    |> binary_chunks(file, opts)
    |> Stream.chunk_while("", &split_chunk/2, &last_line/1)
    |> Stream.flat_map(& &1)
  end

  @spec binary_chunks(binary(), binary(), ExAws.S3.download_file_opts()) :: Enumerable.t()
  defp binary_chunks(bucket, file, opts) do
    download_file_fn = Keyword.get(opts, :download_file_fn, &ExAws.S3.download_file/4)
    stream_fn = Keyword.get(opts, :stream_fn, &ExAws.stream!/1)

    bucket
    |> download_file_fn.(file, :memory, opts)
    |> stream_fn.()
  end

  @spec split_chunk(String.t(), String.t()) ::
          {:cont, [String.t()], String.t()} | {:cont, String.t()}
  defp split_chunk("", line_acc), do: {:cont, [line_acc], ""}

  defp split_chunk(string, line_acc) do
    string
    |> String.split(~r/\R/)
    |> handle_chunks(line_acc)
  end

  @spec handle_chunks([String.t()], String.t()) ::
          {:cont, [String.t()], String.t()} | {:cont, String.t()}
  defp handle_chunks([line_chunk], line_acc), do: {:cont, [line_acc <> line_chunk]}

  defp handle_chunks([end_of_line, start_of_next_line, ""], line_acc),
    do: {:cont, [line_acc <> end_of_line], start_of_next_line}

  defp handle_chunks([end_of_line, start_of_next_line], line_acc),
    do: {:cont, [line_acc <> end_of_line], start_of_next_line}

  defp handle_chunks([end_of_line | remaining_lines], line_acc) do
    finished_line = line_acc <> end_of_line
    {start_of_next_line, middle_lines} = List.pop_at(remaining_lines, -1)

    {:cont, [finished_line | middle_lines], start_of_next_line}
  end

  @spec last_line(String.t()) :: {:cont, [String.t()], String.t()} | {:cont, String.t()}
  defp last_line(""), do: {:cont, ""}
  defp last_line(acc), do: {:cont, [String.trim(acc)], ""}
end
