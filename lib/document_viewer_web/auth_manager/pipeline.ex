defmodule DocumentViewerWeb.AuthManager.Pipeline do
  @moduledoc """
  Custom Guardian pipeline.
  """

  # This sets up Guardian so that we can build / parse tokens found in a request as per
  # the DocumentViewerWeb.AuthManager, and ensures errors are handled as per ErrorHandler.
  use Guardian.Plug.Pipeline,
    otp_app: :document_viewer,
    module: DocumentViewerWeb.AuthManager,
    error_handler: DocumentViewerWeb.AuthManager.ErrorHandler

  # The first plug checks the session for a JWT token...
  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  # If a token was not found in the session, we check the headers here.
  # If a token is found thereafter it can be accessed via Guardian.Plug.current_token().
  # The `claims: %{"typ" => "access"}` specifies that the token should be an access token
  # (as opposed to a refresh token for example).
  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})
  # This takes the token found from above (if one is found) and calls
  # our resource_from_claims/1 callback defined in DocumentViewerWeb.AuthManager. That would
  # let us find the relevant user if we had one, but generally lets us inspect the claims
  # found in the token and do something with them.
  plug(Guardian.Plug.LoadResource, allow_blank: true)

  # Finally if we never found a token above this plug will call the error handler
  # `DocumentViewerWeb.AuthManager.ErrorHandler` above with :unauthenticated as a reason.
  plug(Guardian.Plug.EnsureAuthenticated)
end
