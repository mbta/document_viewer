defmodule DocumentViewerWeb.Router do
  use DocumentViewerWeb, :router

  pipeline :auth do
    plug DocumentViewerWeb.AuthManager.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :ensure_document_viewer_group do
    plug DocumentViewerWeb.EnsureDocumentViewerGroup
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/auth", DocumentViewerWeb do
    pipe_through :browser

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
  end

  scope "/", DocumentViewerWeb do
    pipe_through [
      :browser,
      :auth,
      :ensure_auth,
      :ensure_document_viewer_group
    ]

    get("/", QueryController, :new)
    post("/", QueryController, :search)
    get("/documents/:bucket_name/:file_path", DocumentController, :show)
    get("/documents/:bucket_name/:file_path/pdf", DocumentController, :pdf)
  end

  # Load balancer health check
  # Exempt from auth checks and SSL redirects
  scope "/", DocumentViewerWeb do
    get("/_health", HealthController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", DocumentViewerWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: DocumentViewerWeb.Telemetry)
    end
  end
end
