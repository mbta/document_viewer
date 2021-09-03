defmodule DocumentViewerWeb.UploadControllerTest do
  use DocumentViewerWeb.ConnCase

  describe "create: POST /api/upload" do
    @tag :with_api_token
    test "returns the bucket and path where the file was uploaded", %{conn: conn} do
      upload_fn = fn _, _, _, _ ->
        {:ok, %{bucket: "TEST_BUCKET", path: "TEST_PATH"}}
      end

      upload = %Plug.Upload{
        path: "test/fixtures/example.jpg",
        filename: "example.jpg"
      }

      conn =
        conn
        |> assign(:upload_fn, upload_fn)
        |> post("/api/upload", %{
          :file => upload,
          :environment => "pre-prod",
          :form => "youth-pass"
        })

      assert json_response(conn, 200) == %{"bucket" => "TEST_BUCKET", "path" => "TEST_PATH"}
    end

    @tag :with_api_token
    test "responds with bad request if any required parameters are missing", %{conn: conn} do
      conn = post(conn, "/api/upload")

      assert json_response(conn, 400) == %{"message" => "Bad request"}
    end

    test "responds with unauthorized if the auth token is missing or wrong", %{conn: conn} do
      conn = post(conn, "/api/upload")

      assert response(conn, 401) == "Unauthorized"
    end
  end
end