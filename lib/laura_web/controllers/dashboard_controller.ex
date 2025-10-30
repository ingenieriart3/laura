# lib/laura_web/controllers/dashboard_controller.ex
defmodule LauraWeb.DashboardController do
  use LauraWeb, :controller

  def index(conn, _params) do
    staff_id = get_session(conn, :staff_id)

    if staff_id do
      render(conn, :index)
    else
      conn
      |> put_flash(:error, "Debes iniciar sesión")
      |> redirect(to: "/auth")
    end
  end
end
