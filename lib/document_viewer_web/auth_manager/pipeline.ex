defmodule DocumentViewerWeb.AuthManager.Pipeline do
  @moduledoc """
  Custom Guardian pipeline.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :document_viewer,
    module: DocumentViewerWeb.AuthManager,
    error_handler: DocumentViewerWeb.AuthManager.ErrorHandler

  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
