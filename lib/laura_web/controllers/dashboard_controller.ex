# lib/laura_web/controllers/dashboard_controller.ex
defmodule LauraWeb.DashboardController do
  use LauraWeb, :controller
  alias Laura.{Accounts, Platform, Repo}

  def index(conn, _params) do
    current_staff = conn.assigns[:current_staff]

    if current_staff do
      # Cargar health_brand con subscription_plan precargado
      health_brand = Platform.get_health_brand!(current_staff.health_brand_id)
      health_brand_with_plan = Repo.preload(health_brand, :subscription_plan)

      render(conn, :index,
        current_staff: current_staff,
        health_brand: health_brand_with_plan
      )
    else
      conn
      |> put_flash(:error, "Debes iniciar sesión")
      |> redirect(to: "/auth")
    end
  end
end
