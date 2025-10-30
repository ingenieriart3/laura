# defmodule Laura.Emails.MagicLinkEmail do
#   use Swoosh.Mailer

#   import Swoosh.Email

#   def magic_link(staff, magic_link_url, health_brand) do
#     new()
#     |> to(staff.email)
#     |> from({"Laura Health", "hola@laurahealth.com"})
#     |> subject("Tu acceso seguro a #{health_brand.name}")
#     |> html_body(html_template(staff, magic_link_url, health_brand))
#     |> text_body(text_template(staff, magic_link_url, health_brand))
#   end

#   defp html_template(staff, magic_link_url, health_brand) do
#     """
#     <!DOCTYPE html>
#     <html>
#     <head>
#       <meta charset="utf-8">
#       <style>
#         body { font-family: 'Arial', sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
#         .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
#         .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
#         .button { background: #667eea; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 20px 0; }
#         .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
#       </style>
#     </head>
#     <body>
#       <div class="header">
#         <h1>🔐 Acceso Seguro</h1>
#         <h2>#{health_brand.name}</h2>
#       </div>
#       <div class="content">
#         <p>Hola,</p>
#         <p>Has solicitado acceder a la plataforma de <strong>#{health_brand.name}</strong>. Haz clic en el botón para ingresar:</p>

#         <div style="text-align: center;">
#           <a href="#{magic_link_url}" class="button">Ingresar a Mi Cuenta</a>
#         </div>

#         <p><strong>Este enlace expira en 15 minutos</strong> y es de un solo uso.</p>

#         <p>Si no solicitaste este acceso, puedes ignorar este mensaje.</p>

#         <div class="footer">
#           <p>© #{DateTime.utc_now().year} Laura Health - Todos los derechos reservados</p>
#           <p><small>Este es un mensaje automático, por favor no respondas a este email.</small></p>
#         </div>
#       </div>
#     </body>
#     </html>
#     """
#   end

#   defp text_template(staff, magic_link_url, health_brand) do
#     """
#     Acceso Seguro - #{health_brand.name}

#     Hola,

#     Has solicitado acceder a la plataforma de #{health_brand.name}.
#     Usa el siguiente enlace para ingresar:

#     #{magic_link_url}

#     Este enlace expira en 15 minutos y es de un solo uso.

#     Si no solicitaste este acceso, puedes ignorar este mensaje.

#     © #{DateTime.utc_now().year} Laura Health - Todos los derechos reservados
#     """
#   end
# end


defmodule Laura.Emails.MagicLinkEmail do
  def magic_link(staff, magic_link_url, health_brand) do
    %{
      to: staff.email,
      from: "hola@laurahealth.com",
      subject: "Tu acceso seguro a #{health_brand.name}",
      html: generate_html(staff, magic_link_url, health_brand),
      text: generate_text(staff, magic_link_url, health_brand)
    }
  end

  defp generate_html(staff, magic_link_url, health_brand) do
    # Template HTML simple
    """
    <h1>Acceso a #{health_brand.name}</h1>
    <p>Haz clic <a href="#{magic_link_url}">aquí</a> para ingresar.</p>
    <p>Este enlace expira en 15 minutos.</p>
    """
  end

  defp generate_text(staff, magic_link_url, health_brand) do
    "Acceso: #{magic_link_url}"
  end
end
