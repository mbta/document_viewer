defmodule DocumentViewerWeb.HealthController do
  @moduledoc """
  Simple controller to return 200 OK when the app is healthy.
  """
  use DocumentViewerWeb, :controller

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    health_server_pid = conn.assigns[:health_server_pid] || Catalog.Health

    if Catalog.Health.ready?(health_server_pid) do
      send_resp(conn, :ok, "ok")
    else
      send_resp(conn, :service_unavailable, "not ready")
    end
  end
end
