defmodule Catalog.Supervisor do
  @moduledoc """
  Supervisor for the Catalog GenServer and corresponding Health GenServer.
  """

  use Supervisor

  def start_link([]) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    children = [
      Catalog.Health,
      Catalog
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
