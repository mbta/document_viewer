defmodule DocumentViewerWeb.AuthController do
  use DocumentViewerWeb, :controller

  require Logger

  plug(Ueberauth)

  alias DocumentViewerWeb.AuthManager
  alias DocumentViewerWeb.Router.Helpers

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    username = auth.uid
    expiration = auth.credentials.expires_at

    current_time = System.system_time(:second)

    conn
    |> Guardian.Plug.sign_in(
      AuthManager,
      username,
      %{},
      ttl: {expiration - current_time, :seconds}
    )
    |> Plug.Conn.put_session(:username, username)
    |> redirect(to: Helpers.query_path(conn, :new))
  end

  # If a user gets a failure from Ueberauth, we want to redirect them away from this site.
  # Since everything on this site requires authorization, they will get trapped
  # in an infinite loop of redirects otherwise.
  def callback(%{assigns: %{ueberauth_failure: ueberauth_failure}} = conn, _params) do
    log_errors(ueberauth_failure)

    conn
    |> Guardian.Plug.sign_out(AuthManager, [])
    |> redirect(external: "https://www.mbta.com")
  end

  defp log_errors(%Ueberauth.Failure{errors: errors}), do: Enum.map(errors, &log_error/1)

  defp log_error(%Ueberauth.Failure.Error{message: message}),
    do: Logger.error("Ueberauth erorr: #{message}")
end
