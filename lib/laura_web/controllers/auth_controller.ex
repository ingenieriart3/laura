# # defmodule LauraWeb.AuthController do
# #   use LauraWeb, :controller
# #   alias Laura.Accounts

# #   def verify_magic_link(conn, %{"token" => token}) do
# #     case Accounts.verify_magic_link(token) do
# #       {:ok, staff} ->
# #         # Iniciar sesión y redirigir al dashboard
# #         conn
# #         |> put_session(:staff_id, staff.id)
# #         |> put_flash(:info, "¡Bienvenido de vuelta!")
# #         |> redirect(to: "/dashboard")

# #       {:error, :invalid_or_expired_token} ->
# #         conn
# #         |> put_flash(:error, "Enlace inválido o expirado")
# #         |> redirect(to: "/auth")

# #       {:error, :update_failed} ->
# #         conn
# #         |> put_flash(:error, "Error al procesar el enlace")
# #         |> redirect(to: "/auth")
# #     end
# #   end
# # end
# defmodule LauraWeb.AuthController do
#   use LauraWeb, :controller
#   alias Laura.Accounts

#   def verify_magic_link(conn, %{"token" => token}) do
#     IO.puts("🔐 Verificando magic link: #{token}")

#     case Accounts.verify_magic_link(token) do
#       {:ok, staff} ->
#         IO.puts("✅ Magic link válido para: #{staff.email}")

#         conn
#         |> put_session(:staff_id, staff.id)
#         |> put_flash(:info, "¡Bienvenido de vuelta, #{staff.email}!")
#         |> redirect(to: "/dashboard")

#       {:error, :invalid_or_expired_token} ->
#         IO.puts("❌ Magic link inválido o expirado: #{token}")

#         conn
#         |> put_flash(:error, "Enlace inválido o expirado. Solicita uno nuevo.")
#         |> redirect(to: "/auth")

#       {:error, :update_failed} ->
#         IO.puts("❌ Error actualizando magic link: #{token}")

#         conn
#         |> put_flash(:error, "Error al procesar el enlace. Intenta nuevamente.")
#         |> redirect(to: "/auth")
#     end
#   end
# end


# lib/laura_web/controllers/auth_controller.ex
defmodule LauraWeb.AuthController do
  use LauraWeb, :controller
  alias Laura.Accounts

  def verify_magic_link(conn, %{"token" => token}) do
    IO.puts("🔐 Verificando magic link: #{token}")

    case Accounts.verify_magic_link(token) do
      {:ok, staff} ->
        IO.puts("✅ Magic link válido para: #{staff.email}")

        conn
        |> put_session(:staff_id, staff.id)
        |> put_session(:staff_email, staff.email)
        |> put_session(:health_brand_id, staff.health_brand_id)
        |> put_flash(:info, "¡Bienvenido de vuelta, #{staff.email}!")
        |> redirect(to: "/dashboard")

      {:error, :invalid_or_expired_token} ->
        IO.puts("❌ Magic link inválido o expirado: #{token}")

        conn
        |> put_flash(:error, "Enlace inválido o expirado. Solicita uno nuevo.")
        |> redirect(to: "/auth")

      {:error, :update_failed} ->
        IO.puts("❌ Error actualizando magic link: #{token}")

        conn
        |> put_flash(:error, "Error al procesar el enlace. Intenta nuevamente.")
        |> redirect(to: "/auth")
    end
  end

  # Opcional: Logout
  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Has cerrado sesión correctamente")
    |> redirect(to: "/auth")
  end
end
