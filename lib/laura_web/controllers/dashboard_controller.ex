defmodule LauraWeb.DashboardController do
  use LauraWeb, :controller
  alias Laura.{Accounts, Platform, Repo, Scheduling, MedicalRecord, Billing, Analytics}

  def index(conn, _params) do
    current_staff = conn.assigns[:current_staff]
    health_brand = conn.assigns.health_brand

    if current_staff do
      # Verificar que el staff pertenece al health_brand del subdominio
      if current_staff.health_brand_id == health_brand.id do
        # Cargar datos completos para el dashboard
        health_brand_with_plan = Repo.preload(health_brand, :subscription_plan)

        # Obtener métricas del dashboard
        dashboard_data = get_dashboard_data(health_brand.id)

        render(conn, :index,
          current_staff: current_staff,
          health_brand: health_brand_with_plan,
          dashboard_data: dashboard_data
        )
      else
        # Staff no pertenece a este health_brand
        conn
        |> put_flash(:error, "No tienes acceso a este tenant")
        |> redirect(to: "/auth/logout")
      end
    else
      conn
      |> put_flash(:error, "Debes iniciar sesión")
      |> redirect(to: "/auth")
    end
  end

  defp get_dashboard_data(health_brand_id) do
    %{
      total_patients: length(Accounts.list_patients(health_brand_id)),
      upcoming_appointments: length(Scheduling.list_appointments(health_brand_id, status: "scheduled")),
      completed_appointments: length(Scheduling.list_appointments(health_brand_id, status: "completed")),
      active_treatments: length(MedicalRecord.list_treatments(health_brand_id) |> Enum.filter(&(&1.status == "active"))),
      pending_invoices: length(Billing.list_invoices(health_brand_id) |> Enum.filter(&(&1.status == "sent"))),
      metrics: Analytics.get_dashboard_metrics(health_brand_id)
    }
  end
end
