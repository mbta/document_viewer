defmodule Catalog do
  @moduledoc """
  A listing of all documents in our collection of buckets. The buckets are specified in the application configuration. Each document is associated with a person, and can be searched by that person's last name, first name, and/or date of birth.
  """
  use GenServer

  require Logger

  alias Catalog.{Bucket, Document}

  @type t :: %__MODULE__{
          ets: :ets.tid()
        }

  @enforce_keys [:ets]

  defstruct ets: nil

  # Client

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)

    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @spec lookup(String.t() | nil, String.t() | nil, Date.t() | nil) ::
          {:ok, [Document.t()]} | {:error, String.t()}
  @spec lookup(GenServer.server(), String.t() | nil, String.t() | nil, Date.t() | nil) ::
          {:ok, [Document.t()]} | {:error, String.t()}
  def lookup(pid \\ __MODULE__, last_name, first_name, date_of_birth)

  def lookup(_, nil, nil, nil),
    do: {:error, "Bad request. You must include at least one field to search on."}

  def lookup(pid, last_name, first_name, date_of_birth) do
    GenServer.call(pid, {:lookup, last_name, first_name, date_of_birth})
  end

  # Server

  @impl GenServer
  def init(opts) do
    if Application.fetch_env!(:document_viewer, :live_catalog?) do
      ets = :ets.new(__MODULE__, [:set, :protected])

      {:ok, %__MODULE__{ets: ets}, {:continue, {:load_documents, opts}}}
    else
      :ignore
    end
  end

  @impl GenServer
  @spec handle_continue({:load_documents, keyword()}, t()) :: {:noreply, t()}
  def handle_continue({:load_documents, opts}, %__MODULE__{ets: ets} = state) do
    documents_fn = Keyword.get(opts, :documents_fn, &all_documents/0)

    Logger.info(fn -> "Loading document metadata" end)

    {time_in_μs, _} = :timer.tc(&populate_ets_table/2, [ets, documents_fn])

    # Let the health server know that the data has finished loading
    Catalog.Health.loaded()

    Logger.info(fn ->
      "Finished loading document metadata, time_in_ms=#{time_in_μs / 1_000}"
    end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_call(
        {:lookup, last_name, first_name, date_of_birth},
        _from,
        %__MODULE__{ets: ets} = state
      ) do
    results =
      ets
      |> :ets.match(
        {:_, search_term(last_name), search_term(first_name), search_term(date_of_birth), :"$1"}
      )
      |> List.flatten()

    {:reply, results, state}
  end

  @spec populate_ets_table(:ets.tid(), (-> [t()])) :: true
  defp populate_ets_table(ets, documents_fn) do
    records =
      for document <- documents_fn.() do
        {Document.key(document), document.last_name, document.first_name, document.date_of_birth,
         document}
      end

    :ets.insert(ets, records)
  end

  @spec all_documents() :: [t()]
  defp all_documents do
    buckets()
    |> Enum.map(&Bucket.metadata_files/1)
    |> parse_metadata_files()
  end

  @spec buckets() :: [Bucket.t()]
  defp buckets do
    Application.fetch_env!(:document_viewer, :buckets)
  end

  @type bucket_documents :: [{Bucket.name(), [Document.file_path()]}]
  @spec parse_metadata_files(bucket_documents()) :: [t()]
  defp parse_metadata_files(bucket_documents) do
    for {bucket, file_paths} <- bucket_documents,
        file_path <- file_paths,
        file <- parse_files(bucket, file_path) do
      file
    end
  end

  @spec parse_files(Bucket.name(), Document.file_path()) :: [Document.t()]
  defp parse_files(bucket_name, file_path) do
    bucket_name
    |> S3.BinaryStream.binary_chunks(file_path)
    |> S3.LineStream.lines()
    |> Stream.map(&Document.from_metadata(&1, bucket_name, file_path))
    |> Enum.to_list()
  end

  @spec search_term(String.t() | Date.t() | nil) :: String.t() | Date.t() | atom()
  defp search_term(nil), do: :_
  defp search_term(term), do: term
end
