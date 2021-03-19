defmodule S3.LineStreamTest do
  use ExUnit.Case, async: true

  alias S3.LineStream

  describe "lines/3" do
    test "returns content line-by-line" do
      stream = Stream.map(["abc\nde", "fg\nhij\n"], & &1)

      list =
        stream
        |> LineStream.lines()
        |> Enum.to_list()

      assert list == ["abc", "defg", "hij"]
    end

    test "handles \r\n newline characters" do
      stream = Stream.map(["abc\r\nde", "fg\r\nhij\r\n"], & &1)

      list =
        stream
        |> LineStream.lines()
        |> Enum.to_list()

      assert list == ["abc", "defg", "hij"]
    end

    test "handles no end of file newline" do
      stream = Stream.map(["abc\r\nde", "fg\r\nhij"], & &1)

      list =
        stream
        |> LineStream.lines()
        |> Enum.to_list()

      assert list == ["abc", "defg", "hij"]
    end

    test "handles multiple lines per chunk" do
      stream = Stream.map(["abc\r\ndef\r\ngh", "i\r\njk\r\nlm\r\nno\r\n"], & &1)

      list =
        stream
        |> LineStream.lines()
        |> Enum.to_list()

      assert list == ["abc", "def", "ghi", "jk", "lm", "no"]
    end

    test "handles a chunk which ends with a newline" do
      stream = Stream.map(["abc\n", "def\nghi\n"], & &1)

      list =
        stream
        |> LineStream.lines()
        |> Enum.to_list()

      assert list == ["abc", "def", "ghi"]
    end

    test "handles a final chunk with just a newline" do
      stream = Stream.map(["abc\r\nde", "fg\r\nhij\r\n", "\r\n"], & &1)

      list =
        stream
        |> LineStream.lines()
        |> Enum.to_list()

      assert list == ["abc", "defg", "hij"]
    end

    test "handles a chunk with no newlines" do
      stream = Stream.map(["a", "b", "c\ndef\n"], & &1)

      list =
        stream
        |> LineStream.lines()
        |> Enum.to_list()

      assert list == ["abc", "def"]
    end
  end
end
