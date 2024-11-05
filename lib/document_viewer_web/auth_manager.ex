defmodule DocumentViewerWeb.AuthManager do
  @moduledoc """
  Custom Guardian auth manager. Guardian is the library responsible for creating tokens and
  parsing / verifying them out of requests. We use JWTs which are the default tokens
  Guardian expects. This module implements callbacks that get called when a token is being
  created or read. The callbacks do things like let us add data into the token or use data
  pulled out of the token to do things.
  """

  use Guardian, otp_app: :document_viewer

  @impl Guardian
  @doc """
  To create a token we call Guardian.encode_and_sign/4 passing it a resource as the second
  arg and claims as the optional 3rd arg. That resource is used to build out the "Registered
  claims" of the JWT. Registered claims are standardized bits of data we put into a token
  that get used by whoever receives it to do things like check the token is still valid and
  find the user the token should belong to.

  https://auth0.com/docs/secure/tokens/json-web-tokens/json-web-token-claims#registered-claims

  `Guardian.encode_and_sign/4` calls this callback as part of building a valid token, putting
  the resource we give to encode_and_sign/4 as the first argument and the optional claims as
  the second arg.

  Usually the resource might be something like a `User` struct, and we might choose to use the
  ID of that user as the "sub" (subject) for the token, so that we can later parse the ID
  out of the token and fetch the correct user with it. In this app there are no Users so to
  speak so our resource is just a username and we don't really do anything with it.
  """
  def subject_for_token(resource, _claims) do
    {:ok, resource}
  end

  @impl Guardian
  @doc """
  This callback gets called when we are parsing / validating a token. It gets given the claims
  found in there and it's on us to do something with them. Normally you might expect an ID
  as the "sub" field which could be used to find a user, erroring if we cannot find them.
  This app does not have a database and therefore does not have a user that we can look up
  so we don't do anything but check that there is a sub.
  """
  def resource_from_claims(%{"sub" => username}) do
    {:ok, username}
  end

  def resource_from_claims(_), do: {:error, :invalid_claims}
end
