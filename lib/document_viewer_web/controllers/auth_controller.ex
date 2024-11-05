defmodule DocumentViewerWeb.AuthController do
  use DocumentViewerWeb, :controller

  require Logger
  @document_viewer_role "document-viewer-admin"
  def document_viewer_role, do: @document_viewer_role

  # This handles implements the request/2 function that Plug will call. That implementation
  # will create a valid Keycloak request and ensure that callback/2 below gets called when
  # we return from keycloak to here.
  plug(Ueberauth)

  alias DocumentViewerWeb.AuthManager
  alias DocumentViewerWeb.UserActionLogger

  @doc """
  This is called when a user returns from logging in. They'll return with information that
  Ueberauth extracts from the request and puts into assigns for us, which we can then use
  to ensure the user is allowed to see what they are asking to see.
  """
  def callback(
        %{
          assigns: %{
            ueberauth_auth: %Ueberauth.Auth{
              uid: username,
              credentials: credentials,
              extra: extra,
              provider: :keycloak
            }
          }
        } = conn,
        _params
      ) do
    expiration = credentials.expires_at
    current_time = System.system_time(:second)

    client_id = extra.raw_info.claims["aud"]
    roles = extra.raw_info.userinfo["resource_access"][client_id]["roles"] || []

    UserActionLogger.log(username, :login)

    time_left = expiration - current_time

    if @document_viewer_role in roles do
      conn
      |> Guardian.Plug.sign_in(AuthManager, username, %{roles: roles}, ttl: {time_left, :seconds})
      |> Plug.Conn.put_session(:username, username)
      |> redirect(to: ~p"/")
    else
      Logger.warning("Document viewer role not found in the roles for user: #{roles}")
      redirect_to_dotcom(conn)
    end
  end

  def callback(%{assigns: %{ueberauth_failure: ueberauth_failure}} = conn, _params) do
    log_errors(ueberauth_failure)
    redirect_to_dotcom(conn)
  end

  # If a user gets a failure from Ueberauth, we want to redirect them away from this site.
  # Since everything on this site requires authorization, they will get trapped
  # in an infinite loop of redirects otherwise.
  defp redirect_to_dotcom(conn) do
    conn
    |> Guardian.Plug.sign_out(AuthManager, [])
    |> redirect(external: "https://www.mbta.com")
  end

  defp log_errors(%Ueberauth.Failure{errors: errors}), do: Enum.map(errors, &log_error/1)

  defp log_error(%Ueberauth.Failure.Error{message: message}),
    do: Logger.error("Ueberauth error: #{message}")
end
