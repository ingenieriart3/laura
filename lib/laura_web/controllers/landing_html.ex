# # lib/laura_web/controllers/landing_html.ex
# defmodule LauraWeb.LandingHTML do
#   use LauraWeb, :html

#   embed_templates "landing_html/*"
# end

defmodule LauraWeb.LandingHTML do
  use LauraWeb, :html

  embed_templates "landing_html/*"

  def feature_to_text(feature) do
    case feature do
      :whatsapp_reminders -> "Recordatorios por WhatsApp"
      :basic_analytics -> "Analytics básicos"
      :advanced_analytics -> "Analytics avanzados"
      :premium_analytics -> "Analytics premium"
      :email_support -> "Soporte por email"
      :priority_support -> "Soporte prioritario"
      :dedicated_support -> "Soporte dedicado"
      :custom_branding -> "Branding personalizado"
      :api_access -> "Acceso a API"
      _ -> to_string(feature)
    end
  end

  # Helper function para el template pricing
  def translate_feature(feature) do
    case feature do
      "medical_records" -> "Historias clínicas"
      "appointments" -> "Gestión de citas"
      "basic_analytics" -> "Analíticas básicas"
      "advanced_analytics" -> "Analíticas avanzadas"
      "whatsapp_reminders" -> "Recordatorios WhatsApp"
      "inventory" -> "Control de inventario"
      "api_access" -> "Acceso API"
      _ -> String.replace(feature, "_", " ") |> String.capitalize()
    end
  end
end
