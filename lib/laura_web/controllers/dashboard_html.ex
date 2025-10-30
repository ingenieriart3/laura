defmodule LauraWeb.DashboardHTML do
  use LauraWeb, :html

  embed_templates "dashboard_html/*"

  def trial_status_color(health_brand) do
    case health_brand.subscription_status do
      "trial" -> "bg-green-100"
      "active" -> "bg-blue-100"
      "past_due" -> "bg-yellow-100"
      "canceled" -> "bg-red-100"
      _ -> "bg-gray-100"
    end
  end

  def trial_status_text(health_brand) do
    case health_brand.subscription_status do
      "trial" -> "Trial Activo"
      "active" -> "Plan Activo"
      "past_due" -> "Pago Pendiente"
      "canceled" -> "Cancelado"
      _ -> "Desconocido"
    end
  end

  def trial_ends_text(health_brand) do
    if health_brand.trial_ends_at do
      "Trial hasta: #{Calendar.strftime(health_brand.trial_ends_at, "%d/%m/%Y")}"
    else
      "Sin fecha de fin"
    end
  end
end
