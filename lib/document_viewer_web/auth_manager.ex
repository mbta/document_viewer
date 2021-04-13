defmodule DocumentViewerWeb.AuthManager do
  @moduledoc """
  Custom Guardian auth manager.
  """

  use Guardian, otp_app: :document_viewer

  def subject_for_token(resource, _claims) do
    {:ok, resource}
  end

  def resource_from_claims(%{"sub" => username}) do
    {:ok, username}
  end

  def resource_from_claims(_), do: {:error, :invalid_claims}
end
