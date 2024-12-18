defmodule DocumentViewerWeb.Ueberauth.Strategy.FakeTest do
  use ExUnit.Case, async: true

  alias DocumentViewerWeb.Ueberauth.Strategy.Fake
  alias Ueberauth.Auth.{Credentials, Extra, Info}

  test "credentials returns a credentials struct" do
    assert Fake.credentials(%{}) == %Credentials{
             token: "fake_access_token",
             refresh_token: "fake_refresh_token",
             expires: true,
             expires_at: System.system_time(:second) + 60 * 60
           }
  end

  test "info returns an empty Info struct" do
    assert Fake.info(%{}) == %Info{}
  end

  test "extra returns an Extra struct with expected roles" do
    assert Fake.extra(%{}) == %Extra{
             raw_info: %{
               claims: %{"aud" => "fake_aud"},
               userinfo: %{
                 "resource_access" => %{
                   "fake_aud" => %{
                     "roles" => ["document-viewer-admin"]
                   }
                 }
               }
             }
           }
  end
end
