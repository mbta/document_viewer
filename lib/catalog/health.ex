defmodule Catalog.Health do
  @moduledoc """
  GenServer to keep track of whether the Catalog is up and running with all documents loaded.
  """

  use GenServer

  @type state :: :not_ready | :ready

  # Client

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @spec loaded() :: :ok
  @spec loaded(GenServer.server()) :: :ok
  def loaded(pid \\ __MODULE__) do
    GenServer.cast(pid, :loaded)
  end

  @spec ready?() :: boolean()
  @spec ready?(GenServer.server()) :: boolean()
  def ready?(pid \\ __MODULE__) do
    GenServer.call(pid, :ready?)
  end

  # Server

  @impl GenServer
  def init(_opts) do
    {:ok, :not_ready}
  end

  @impl true
  def handle_cast(:loaded, _state), do: {:noreply, :ready}

  @impl true
  def handle_call(:ready?, _from, :not_ready = state), do: {:reply, false, state}
  def handle_call(:ready?, _from, :ready = state), do: {:reply, true, state}
end
