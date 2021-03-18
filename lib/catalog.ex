defmodule Catalog do
  use GenServer

  alias Catalog.{Bucket, Document}

  @type t :: %__MODULE__{
          ets: :ets.tid(),
          loaded?: boolean()
        }

  @enforce_keys [:ets, :loaded?]

  defstruct ets: nil,
            loaded?: false

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
  @spec init(keyword()) :: {:ok, t(), {:continue, {:load_documents, keyword()}}}
  def init(opts) do
    ets = :ets.new(__MODULE__, [:set, :protected])

    {:ok, %__MODULE__{ets: ets, loaded?: false}, {:continue, {:load_documents, opts}}}
  end

  @impl GenServer
  @spec handle_continue({:load_documents, keyword()}, t()) :: {:noreply, t()}
  def handle_continue({:load_documents, opts}, %__MODULE__{ets: ets, loaded?: false} = state) do
    documents_fn = Keyword.get(opts, :documents_fn, &all_documents/0)

    for document <- documents_fn.() do
      _ =
        :ets.insert(
          ets,
          {Document.key(document), document.last_name, document.first_name,
           document.date_of_birth, document}
        )
    end

    {:noreply, %__MODULE__{state | loaded?: true}}
  end

  @impl GenServer
  def handle_call(
        {:lookup, last_name, first_name, date_of_birth},
        _from,
        %__MODULE__{ets: ets} = state
      ) do
    results =
      ets
      |> :ets.match_object(
        {:_, search_term(last_name), search_term(first_name), search_term(date_of_birth), :_}
      )
      |> Enum.map(fn {_key, _last, _first, _dob, document} -> document end)

    {:reply, results, state}
  end

  @spec all_documents() :: [t()]
  defp all_documents() do
    buckets()
    |> Enum.map(&Bucket.metadata_files/1)
    |> parse_metadata_files()
  end

  @spec buckets() :: [Bucket.t()]
  defp buckets() do
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
    |> S3.ObjectStream.lines(file_path)
    |> Stream.map(&Document.from_metadata(&1, bucket_name, file_path))
    |> Enum.to_list()
  end

  @spec search_term(String.t() | Date.t() | nil) :: String.t() | Date.t() | atom()
  defp search_term(nil), do: :_
  defp search_term(term), do: term
end
