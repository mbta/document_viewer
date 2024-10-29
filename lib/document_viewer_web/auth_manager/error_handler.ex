defmodule DocumentViewerWeb.AuthManager.ErrorHandler do
  @moduledoc """
  Custom Guardian error handler. If we ever get a token that does not seem valid this gets
  called.
  """

  @behaviour Guardian.Plug.ErrorHandler
  use DocumentViewerWeb, :verified_routes

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, reason}, _opts)
      when reason in [:unauthenticated, :token_expired] do
    Phoenix.Controller.redirect(conn, to: ~p"/auth/keycloak")
  end
end
