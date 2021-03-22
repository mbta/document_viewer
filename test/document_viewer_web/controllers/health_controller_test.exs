defmodule DocumentViewerWeb.HealthControllerTest do
  use DocumentViewerWeb.ConnCase

  alias Catalog.Health

  describe "index" do
    test "returns 200 when health server is ready", %{conn: conn} do
      {:ok, health_server_pid} = Health.start_link(name: :controller_ready_test)
      Health.loaded(health_server_pid)

      response =
        conn
        |> Plug.Conn.assign(:health_server_pid, health_server_pid)
        |> get(Routes.health_path(conn, :index))

      assert response.status == 200
    end

    test "returns 503 when health server is not ready", %{conn: conn} do
      {:ok, health_server_pid} = Health.start_link(name: :controller_ready_test)

      response =
        conn
        |> Plug.Conn.assign(:health_server_pid, health_server_pid)
        |> get(Routes.health_path(conn, :index))

      assert response.status == 503
    end
  end
end
