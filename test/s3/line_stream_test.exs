defmodule S3.LineStreamTest do
  use ExUnit.Case, async: true

  alias S3.LineStream

  doctest LineStream

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
  end
end
