# defmodule LauraWeb.Router do
#   use LauraWeb, :router

#   pipeline :browser do
#     plug :accepts, ["html"]
#     plug :fetch_session
#     plug :fetch_live_flash
#     plug :put_root_layout, html: {LauraWeb.Layouts, :root}
#     plug :protect_from_forgery
#     plug :put_secure_browser_headers
#   end

#   pipeline :api do
#     plug :accepts, ["json"]
#   end

#   scope "/", LauraWeb do
#     pipe_through :browser

#     get "/", PageController, :home
#   end

#   # Other scopes may use custom stacks.
#   # scope "/api", LauraWeb do
#   #   pipe_through :api
#   # end

#   # Enable LiveDashboard and Swoosh mailbox preview in development
#   if Application.compile_env(:laura, :dev_routes) do
#     # If you want to use the LiveDashboard in production, you should put
#     # it behind authentication and allow only admins to access it.
#     # If your application does not have an admins-only section yet,
#     # you can use Plug.BasicAuth to set up some basic authentication
#     # as long as you are also using SSL (which you should anyway).
#     import Phoenix.LiveDashboard.Router

#     scope "/dev" do
#       pipe_through :browser

#       live_dashboard "/dashboard", metrics: LauraWeb.Telemetry
#       forward "/mailbox", Plug.Swoosh.MailboxPreview
#     end
#   end
# end

# lib/laura_web/router.ex
defmodule LauraWeb.Router do
  use LauraWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LauraWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug LauraWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LauraWeb do
    pipe_through :browser

    # Landing pages globales
    get "/", LandingController, :index
    get "/pricing", LandingController, :pricing
    get "/features", LandingController, :features
    get "/contact", LandingController, :contact

    # Registro
    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create
    get "/welcome", RegistrationController, :welcome

    # lib/laura_web/router.ex
    # get "/debug/styles", DebugController, :test_styles
    live "/debug/styles", DebugLive

    # Dashboard (protegido)
    get "/dashboard", DashboardController, :index

    # ✅ AGREGAR RUTA DE AUTH
    live "/auth", AuthLive
    get "/auth/verify/:token", AuthController, :verify_magic_link
    get "/auth/logout", AuthController, :logout
  end

  # Otras rutas (para más adelante)
  # scope "/:tenant", LauraWeb do
  #   pipe_through [:browser, :tenant_detection]
  #   # Rutas específicas del tenant
  # end
end
