defmodule CatalogTest do
  use ExUnit.Case, async: true

  alias Catalog.Document

  @document_jane_doe_1950 %Document{
    last_name: "Doe",
    first_name: "Jane",
    date_of_birth: ~D[1950-01-01],
    bucket_name: "TEST BUCKET",
    path: "TEST PATH 1"
  }
  @document_jane_doe_2000 %Document{
    last_name: "Doe",
    first_name: "Jane",
    date_of_birth: ~D[2000-07-04],
    bucket_name: "TEST BUCKET",
    path: "TEST PATH 2"
  }
  @document_john_doe %Document{
    last_name: "Doe",
    first_name: "John",
    date_of_birth: ~D[1960-12-25],
    bucket_name: "TEST BUCKET",
    path: "TEST PATH 3"
  }
  @document_mickey_mouse_1950 %Document{
    last_name: "Mouse",
    first_name: "Mickey",
    date_of_birth: ~D[1950-01-01],
    bucket_name: "TEST BUCKET",
    path: "TEST PATH 4"
  }

  describe "init" do
    test "starts up the server" do
      opts = [
        documents_fn: fn -> [] end
      ]

      assert {:ok, _pid} = Catalog.start_link(opts)
    end
  end

  describe "lookup" do
    setup do
      opts = [
        documents_fn: fn ->
          [
            @document_jane_doe_1950,
            @document_jane_doe_2000,
            @document_john_doe,
            @document_mickey_mouse_1950
          ]
        end
      ]

      {:ok, pid} = Catalog.start_link(opts)

      %{pid: pid}
    end

    test "looks up documents by last name", %{pid: pid} do
      assert equal_when_sorted(
               Catalog.lookup(pid, "Doe", nil, nil),
               [@document_jane_doe_1950, @document_jane_doe_2000, @document_john_doe]
             )
    end

    test "looks up documents by first name", %{pid: pid} do
      assert equal_when_sorted(
               Catalog.lookup(pid, nil, "Jane", nil),
               [@document_jane_doe_1950, @document_jane_doe_2000]
             )
    end

    test "looks up documents by date of birth", %{pid: pid} do
      assert equal_when_sorted(
               Catalog.lookup(pid, nil, nil, ~D[1950-01-01]),
               [@document_jane_doe_1950, @document_mickey_mouse_1950]
             )
    end

    test "looks up documents by multiple fields", %{pid: pid} do
      assert equal_when_sorted(
               Catalog.lookup(pid, nil, "Jane", ~D[1950-01-01]),
               [@document_jane_doe_1950]
             )
    end

    test "returns an error if every search argument is nil", %{pid: pid} do
      assert {:error, _message} = Catalog.lookup(pid, nil, nil, nil)
    end
  end

  defp equal_when_sorted(a, b) do
    Enum.sort(a) == Enum.sort(b)
  end
end
