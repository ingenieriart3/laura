# lib/laura_web/controllers/registration_controller.ex
defmodule LauraWeb.RegistrationController do
  use LauraWeb, :controller

  def new(conn, params) do
    plans = Laura.Billing.list_public_subscription_plans()
    default_plan = params["plan"] || "basic"

    render(conn, :new, plans: plans, default_plan: default_plan)
  end

  def create(conn, %{"registration" => _params}) do
    conn
    |> put_flash(:info, "¡Registro exitoso! Próximamente recibirás instrucciones por email.")
    |> redirect(to: "/welcome")
  end

  def welcome(conn, _params) do
    render(conn, :welcome)
  end
end
