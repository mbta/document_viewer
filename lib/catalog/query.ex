defmodule Catalog.Query do
  @moduledoc """
  Schema for validating document search queries.
  """

  use Ecto.Schema

  alias Ecto.{Changeset, Schema}

  @type t :: %__MODULE__{
          last_name: String.t(),
          first_name: String.t(),
          date_of_birth: Date.t()
        }

  embedded_schema do
    field(:last_name, :string)
    field(:first_name, :string)
    field(:date_of_birth, :date)
    field(:date_of_birth_string, :string, virtual: true)
  end

  @spec new() :: Changeset.t()
  def new, do: changeset(%__MODULE__{}, %{})

  @spec changeset(Schema.t(), map()) :: Changeset.t()
  def changeset(document_query, attrs) do
    document_query
    |> Changeset.cast(attrs, [:last_name, :first_name, :date_of_birth_string])
    |> capitalize(:last_name)
    |> capitalize(:first_name)
    |> parse_date()
    |> validate_at_least_one_query_param()
  end

  @spec validate_at_least_one_query_param(Changeset.t()) :: Changeset.t()
  def validate_at_least_one_query_param(changeset) when changeset.changes == %{},
    do: Changeset.add_error(changeset, :last_name, "At least one search field must be included.")

  def validate_at_least_one_query_param(changeset), do: changeset

  @spec capitalize(Changeset.t(), atom()) :: Changeset.t()
  defp capitalize(changeset, field),
    do: do_capitalize(changeset, field, Changeset.get_field(changeset, field))

  @spec do_capitalize(Changeset.t(), atom(), String.t() | nil) :: Changeset.t()
  defp do_capitalize(changeset, _, nil), do: changeset

  defp do_capitalize(changeset, field, value),
    do: Changeset.put_change(changeset, field, String.capitalize(value))

  @spec parse_date(Changeset.t()) :: Changeset.t()
  defp parse_date(%Changeset{changes: %{date_of_birth_string: date_of_birth_string}} = changeset) do
    with %{"day" => day_string, "month" => month_string, "year" => year_string} <-
           Regex.named_captures(
             ~r/(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{4})/,
             date_of_birth_string
           ),
         year <- String.to_integer(year_string),
         month <- String.to_integer(month_string),
         day <- String.to_integer(day_string),
         {:ok, date_of_birth} <- Date.new(year, month, day) do
      Changeset.put_change(changeset, :date_of_birth, date_of_birth)
    else
      _ ->
        Changeset.add_error(
          changeset,
          :date_of_birth_string,
          "Unable to parse date of birth. Please use the format MM/DD/YYYY."
        )
    end
  end

  defp parse_date(changeset), do: changeset
end
