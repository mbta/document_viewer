defmodule S3.ObjectStreamTest do
  use ExUnit.Case, async: true

  alias S3.ObjectStream

  doctest ObjectStream

  describe "lines/3" do
    test "returns content line-by-line" do
      opts = [
        download_file_fn: fn _, _, _, _ -> :ok end,
        stream_fn: fn _ -> Stream.map(["abc\nde", "fg\nhij\n"], & &1) end
      ]

      list =
        "test bucket"
        |> ObjectStream.lines("test file", opts)
        |> Enum.to_list()

      assert list == ["abc", "defg", "hij"]
    end

    test "handles \r\n newline characters" do
      opts = [
        download_file_fn: fn _, _, _, _ -> :ok end,
        stream_fn: fn _ -> Stream.map(["abc\r\nde", "fg\r\nhij\r\n"], & &1) end
      ]

      list =
        "test bucket"
        |> ObjectStream.lines("test file", opts)
        |> Enum.to_list()

      assert list == ["abc", "defg", "hij"]
    end

    test "handles no end of file newline" do
      opts = [
        download_file_fn: fn _, _, _, _ -> :ok end,
        stream_fn: fn _ -> Stream.map(["abc\r\nde", "fg\r\nhij"], & &1) end
      ]

      list =
        "test bucket"
        |> ObjectStream.lines("test file", opts)
        |> Enum.to_list()

      assert list == ["abc", "defg", "hij"]
    end

    test "handles multiple lines per chunk" do
      opts = [
        download_file_fn: fn _, _, _, _ -> :ok end,
        stream_fn: fn _ -> Stream.map(["abc\r\ndef\r\ngh", "i\r\njk\r\nlm\r\nno\r\n"], & &1) end
      ]

      list =
        "test bucket"
        |> ObjectStream.lines("test file", opts)
        |> Enum.to_list()

      assert list == ["abc", "def", "ghi", "jk", "lm", "no"]
    end
  end
end
