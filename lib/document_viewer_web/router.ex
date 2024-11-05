defmodule DocumentViewerWeb.Router do
  use DocumentViewerWeb, :router

  @redirect? Application.compile_env!(:document_viewer, :redirect_http?)

  pipeline :redirect_prod_http do
    if @redirect? do
      plug(Plug.SSL, rewrite_on: [:x_forwarded_proto])
    end
  end

  pipeline :authenticate do
    plug(DocumentViewerWeb.AuthManager.Pipeline)
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
    pipe_through([:redirect_prod_http, :browser])

    # We use Uberauth and UeberauthOidcc to handle SSO in keycloak. That takes care of
    # creating a valid request to keycloak when signing in and parsing the response when
    # the user is redirected back.
    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
  end

  scope "/", DocumentViewerWeb do
    pipe_through [:redirect_prod_http, :browser, :authenticate]

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
