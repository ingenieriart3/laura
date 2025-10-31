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

  pipeline :subdomain do
    plug LauraWeb.Plugs.SubdomainPlug
  end

  pipeline :require_health_brand do
    plug :require_valid_health_brand
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Rutas públicas globales (sin subdominio)
  scope "/", LauraWeb do
    pipe_through :browser

    # Landing pages globales
    get "/", LandingController, :index
    get "/pricing", LandingController, :pricing
    get "/features", LandingController, :features
    get "/contact", LandingController, :contact

    # Debug
    live "/debug/styles", DebugLive
  end

  # Rutas con subdominio (multi-tenant)
  scope "/", LauraWeb do
    pipe_through [:browser, :subdomain]

    # Auth y registro por tenant
    live "/auth", AuthLive
    get "/auth/verify/:token", AuthController, :verify_magic_link
    get "/auth/logout", AuthController, :logout

    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create
    get "/welcome", RegistrationController, :welcome
  end

  # Rutas protegidas que requieren health_brand válido
  scope "/", LauraWeb do
    pipe_through [:browser, :subdomain, :require_health_brand]

    # Dashboard y áreas privadas
    get "/dashboard", DashboardController, :index
  end

  # Plug para requerir health_brand válido
  defp require_valid_health_brand(conn, _opts) do
    case conn.assigns.health_brand do
      nil ->
        conn
        |> put_flash(:error, "Subdominio no válido o cuenta no activa")
        |> redirect(to: "/")
        |> halt()

      health_brand ->
        # Health brand válido, continuar
        conn
    end
  end
end
