defmodule Catalog.HealthTest do
  use ExUnit.Case

  alias Catalog.Health

  describe "loaded" do
    setup do
      {:ok, pid} = Health.start_link(name: :loaded_test)
      %{pid: pid}
    end

    test "tells the health server the data has been loaded and returns :ok", %{pid: pid} do
      assert Health.loaded(pid) == :ok
    end
  end

  describe "ready?" do
    setup do
      {:ok, pid} = Health.start_link(name: :ready_test)
      %{pid: pid}
    end

    test "only true after loaded is called", %{pid: pid} do
      # Starts as not ready
      refute Health.ready?(pid)

      Health.loaded(pid)

      # Ready once data has been loaded
      assert Health.ready?(pid)
    end
  end
end
