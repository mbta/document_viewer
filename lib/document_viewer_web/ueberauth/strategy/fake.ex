defmodule DocumentViewerWeb.Ueberauth.Strategy.Fake do
  @moduledoc """
  Mock Ueberauth strategy for development.
  """
  use DocumentViewerWeb, :verified_routes
  use Ueberauth.Strategy

  @impl Ueberauth.Strategy
  def handle_request!(conn) do
    # Ueberauth does a thing to check for CSRF attacks. It essentially adds a state param
    # that gets checked by ueberauth. This ensures we add it correctly in this fake strategy.
    # https://github.com/ueberauth/ueberauth/pull/136

    # See https://datatracker.ietf.org/doc/html/rfc6749#section-10.12 for more:
    #   > The client MUST implement CSRF protection for its redirection URI.
    #   > This is typically accomplished by requiring any request sent to the
    #   > redirection URI endpoint to include a value that binds the request to
    #   > the user-agent's authenticated state (e.g., a hash of the session
    #   > cookie used to authenticate the user-agent).  The client SHOULD
    #   > utilize the "state" request parameter to deliver this value to the
    #   > authorization server when making an authorization request.
    params = Ueberauth.Strategy.Helpers.with_state_param([], conn)

    conn
    |> redirect!(~p"/auth/keycloak/callback?#{params}")
    |> halt()
  end

  @impl Ueberauth.Strategy
  def handle_callback!(conn) do
    conn
  end

  @impl Ueberauth.Strategy
  def uid(_conn) do
    "fake_uid"
  end

  @impl Ueberauth.Strategy
  def credentials(_conn) do
    %Ueberauth.Auth.Credentials{
      token: "fake_access_token",
      refresh_token: "fake_refresh_token",
      expires: true,
      expires_at: System.system_time(:second) + 60 * 60
    }
  end

  @impl Ueberauth.Strategy
  def info(_conn) do
    %Ueberauth.Auth.Info{}
  end

  @impl Ueberauth.Strategy
  def extra(_conn) do
    %Ueberauth.Auth.Extra{
      raw_info: %{
        claims: %{"aud" => "fake_aud"},
        userinfo: %{
          "resource_access" => %{
            "fake_aud" => %{"roles" => [DocumentViewerWeb.AuthController.document_viewer_role()]}
          }
        }
      }
    }
  end

  @impl Ueberauth.Strategy
  def handle_cleanup!(conn) do
    conn
  end
end
