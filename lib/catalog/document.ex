defmodule Catalog.Document do
  @type file_path :: String.t()

  @type t :: %__MODULE__{
          last_name: String.t(),
          first_name: String.t(),
          date_of_birth: Date.t(),
          scanned_date: Date.t(),
          bucket_name: Bucket.name(),
          path: file_path(),
          metadata_file: file_path()
        }

  @enforce_keys [
    :last_name,
    :first_name,
    :bucket_name,
    :path
  ]

  defstruct [
    :last_name,
    :first_name,
    :date_of_birth,
    :scanned_date,
    :bucket_name,
    :path,
    :metadata_file
  ]

  @spec from_metadata(String.t(), Bucket.name(), file_path()) :: t()
  def from_metadata(metadata, bucket_name, metadata_file) do
    [scanned_date, _, _, last_name, first_name, date_of_birth, path] = String.split(metadata, "|")

    %__MODULE__{
      last_name: String.capitalize(last_name),
      first_name: String.capitalize(first_name),
      date_of_birth: parse_date(date_of_birth),
      scanned_date: parse_date(scanned_date),
      bucket_name: bucket_name,
      path: path,
      metadata_file: metadata_file
    }
  end

  def key(%__MODULE__{bucket_name: bucket_name, path: path}), do: "#{bucket_name}|#{path}"

  # Parses a date string in the format: 01-20-2001
  @spec parse_date(String.t()) :: Date.t()
  defp parse_date(""), do: nil

  defp parse_date(
         <<month_str::binary-size(2), "-", day_str::binary-size(2), "-",
           year_str::binary-size(4)>>
       ) do
    year = String.to_integer(year_str)
    month = String.to_integer(month_str)
    day = String.to_integer(day_str)

    Date.from_erl!({year, month, day})
  end
end
