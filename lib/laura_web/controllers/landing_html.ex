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
end
