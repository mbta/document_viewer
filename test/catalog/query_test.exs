defmodule Catalog.QueryTest do
  use ExUnit.Case, async: true

  alias Catalog.Query
  alias Ecto.Changeset

  describe "new" do
    test "generates an empty changeset" do
      assert %Changeset{data: %Query{}} = Query.new()
    end
  end

  describe "changeset" do
    test "validates that at least one search field is present" do
      one_field = Query.changeset(%Query{}, %{last_name: "LAST"})

      two_fields = Query.changeset(%Query{}, %{last_name: "LAST", first_name: "FIRST"})

      three_fields =
        Query.changeset(%Query{}, %{
          last_name: "LAST",
          first_name: "FIRST",
          date_of_birth_string: "1/1/1970"
        })

      no_fields = Query.changeset(%Query{}, %{})

      assert one_field.valid?
      assert two_fields.valid?
      assert three_fields.valid?
      refute no_fields.valid?
    end

    test "capitalizes the last and first names to match the format of the data in the catalog" do
      query =
        %Query{}
        |> Query.changeset(%{last_name: "LAST", first_name: "first"})
        |> Changeset.apply_changes()

      assert query.last_name == "Last"
      assert query.first_name == "First"
    end

    test "parses the date" do
      query =
        %Query{}
        |> Query.changeset(%{date_of_birth_string: "1/13/1970"})
        |> Changeset.apply_changes()

      assert query.date_of_birth == ~D[1970-01-13]
    end

    test "validates the date of birth date" do
      valid_date = Query.changeset(%Query{}, %{date_of_birth_string: "1/13/1970"})
      invalid_date = Query.changeset(%Query{}, %{date_of_birth_string: "13/1/1970"})
      bad_format = Query.changeset(%Query{}, %{date_of_birth_string: "BADFORMAT"})

      assert valid_date.valid?
      refute invalid_date.valid?
      refute bad_format.valid?
    end
  end
end
