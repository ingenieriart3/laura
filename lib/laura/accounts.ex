# # # defmodule Laura.Accounts do
# # #   import Ecto.Query, warn: false
# # #   alias Laura.Repo
# # #   alias Laura.Accounts.{Staff, StaffRole}

# # #   # Staff Roles
# # #   def list_staff_roles, do: Repo.all(StaffRole)
# # #   def get_staff_role!(id), do: Repo.get!(StaffRole, id)
# # #   def get_staff_role_by_name(name), do: Repo.get_by(StaffRole, name: name)

# # #   # Staff
# # #   def list_staffs, do: Repo.all(Staff)
# # #   def get_staff!(id), do: Repo.get!(Staff, id)

# # #   def get_staff_by_email_and_health_brand(email, health_brand_subdomain) do
# # #     query = from s in Staff,
# # #             join: hb in assoc(s, :health_brand),
# # #             where: s.email == ^email and hb.subdomain == ^health_brand_subdomain,
# # #             where: s.is_active == true,
# # #             preload: [:health_brand, :staff_role]

# # #     case Repo.one(query) do
# # #       nil -> {:error, :not_found}
# # #       staff -> {:ok, staff}
# # #     end
# # #   end

# # #   def create_staff(attrs \\ %{}) do
# # #     %Staff{}
# # #     |> Staff.changeset(attrs)
# # #     |> Repo.insert()
# # #   end

# # #   # Magic Link Authentication
# # #   def request_magic_link(email, health_brand_subdomain, remote_ip) do
# # #     with {:ok, staff} <- get_staff_by_email_and_health_brand(email, health_brand_subdomain),
# # #          {:ok, _staff} <- generate_and_send_magic_link(staff, remote_ip) do
# # #       {:ok, :magic_link_sent}
# # #     end
# # #   end

# # #   defp generate_and_send_magic_link(staff, remote_ip) do
# # #     magic_link_token = generate_magic_link_token()
# # #     expires_at = NaiveDateTime.add(NaiveDateTime.utc_now(), 15 * 60) # 15 minutes

# # #     changeset = Staff.magic_link_changeset(staff, %{
# # #       magic_link_token: magic_link_token,
# # #       magic_link_sent_at: NaiveDateTime.utc_now(),
# # #       magic_link_expires_at: expires_at,
# # #       last_magic_link_ip: remote_ip,
# # #       magic_link_attempts: (staff.magic_link_attempts || 0) + 1
# # #     })

# # #     case Repo.update(changeset) do
# # #       {:ok, staff} ->
# # #         deliver_staff_magic_link(staff, staff.health_brand)
# # #         {:ok, staff}
# # #       {:error, changeset} ->
# # #         {:error, changeset}
# # #     end
# # #   end

# # #   defp generate_magic_link_token do
# # #     :crypto.strong_rand_bytes(32)
# # #     |> Base.url_encode64()
# # #     |> String.replace(~r/[\+\/]/, "-")
# # #     |> String.trim("=")
# # #   end

# # #   # def deliver_staff_magic_link(staff, _health_brand) do
# # #   #   # Usar el endpoint directamente para generar la URL
# # #   #   base_url = LauraWeb.Endpoint.url()
# # #   #   magic_link_url = "#{base_url}/auth/verify/#{staff.magic_link_token}"

# # #   #   # En producción esto enviaría un email real
# # #   #   IO.puts("""
# # #   #   🔐 MAGIC LINK PARA #{staff.email}:
# # #   #   #{magic_link_url}
# # #   #   Expira: #{staff.magic_link_expires_at}
# # #   #   """)

# # #   #   {:ok, %{url: magic_link_url}}
# # #   # end


# # #   # def deliver_staff_magic_link(staff, health_brand) do
# # #   #   base_url = LauraWeb.Endpoint.url()
# # #   #   magic_link_url = "#{base_url}/auth/verify/#{staff.magic_link_token}"

# # #   #   # ENVÍO DE EMAIL REAL
# # #   #   email = MagicLinkEmail.magic_link(staff, magic_link_url, health_brand)

# # #   #   case Laura.Mailer.deliver(email) do
# # #   #     {:ok, _} ->
# # #   #       IO.puts("✅ Email enviado a: #{staff.email}")
# # #   #       {:ok, %{url: magic_link_url, email_sent: true}}

# # #   #     {:error, reason} ->
# # #   #       # Fallback a consola si falla el email
# # #   #       IO.puts("❌ Error enviando email a #{staff.email}: #{inspect(reason)}")
# # #   #       IO.puts("🔐 MAGIC LINK (FALLBACK): #{magic_link_url}")
# # #   #       {:ok, %{url: magic_link_url, email_sent: false}}
# # #   #   end
# # #   # end

# # #   # def deliver_staff_magic_link(staff, _health_brand) do
# # #   #   base_url = LauraWeb.Endpoint.url()
# # #   #   magic_link_url = "#{base_url}/auth/verify/#{staff.magic_link_token}"

# # #   #   # Solo consola por ahora
# # #   #   IO.puts("🎯 MAGIC LINK PARA PRODUCCIÓN:")
# # #   #   IO.puts("📧 #{staff.email}")
# # #   #   IO.puts("🔗 #{magic_link_url}")
# # #   #   IO.puts("⏰ Expira: #{staff.magic_link_expires_at}")

# # #   #   {:ok, %{url: magic_link_url, email_sent: false}}
# # #   # end

# # #   # def deliver_staff_magic_link(staff, health_brand) do
# # #   #   base_url = LauraWeb.Endpoint.url()
# # #   #   magic_link_url = "#{base_url}/auth/verify/#{staff.magic_link_token}"

# # #   #   # Verificar si tenemos configuración de email
# # #   #   case can_send_emails?() do
# # #   #     true ->
# # #   #       # ENVÍO DE EMAIL REAL
# # #   #       email = MagicLinkEmail.magic_link(staff, magic_link_url, health_brand)

# # #   #       case Laura.Mailer.deliver(email) do
# # #   #         {:ok, _} ->
# # #   #           IO.puts("✅ Email enviado a: #{staff.email}")
# # #   #           {:ok, %{url: magic_link_url, email_sent: true}}

# # #   #         {:error, reason} ->
# # #   #           # Fallback a consola si falla el email
# # #   #           IO.puts("❌ Error enviando email: #{inspect(reason)}")
# # #   #           print_magic_link_console(staff, magic_link_url)
# # #   #           {:ok, %{url: magic_link_url, email_sent: false}}
# # #   #       end

# # #   #     false ->
# # #   #       # Modo desarrollo - solo consola
# # #   #       print_magic_link_console(staff, magic_link_url)
# # #   #       {:ok, %{url: magic_link_url, email_sent: false}}
# # #   #   end
# # #   # end

# # #   def deliver_staff_magic_link(staff, health_brand) do
# # #     base_url = LauraWeb.Endpoint.url()
# # #     magic_link_url = "#{base_url}/auth/verify/#{staff.magic_link_token}"

# # #     # Solo modo consola por ahora
# # #     IO.puts("""
# # #     🎯 MAGIC LINK LISTO:
# # #     📧 #{staff.email}
# # #     🔗 #{magic_link_url}
# # #     🏥 #{health_brand.name}
# # #     ⏰ Expira: #{staff.magic_link_expires_at}
# # #     """)

# # #     {:ok, %{url: magic_link_url, email_sent: false}}
# # #   end

# # #   defp can_send_emails? do
# # #     # Verificar si tenemos configuración de SendGrid
# # #     System.get_env("SENDGRID_API_KEY") != nil
# # #   end

# # #   defp print_magic_link_console(staff, magic_link_url) do
# # #     IO.puts("""
# # #     🎯 MAGIC LINK (MODO DESARROLLO):
# # #     📧 Para: #{staff.email}
# # #     🔗 Enlace: #{magic_link_url}
# # #     ⏰ Expira: #{staff.magic_link_expires_at}

# # #     ⚠️  En producción esto sería un email real
# # #     """)
# # #   end

# # #   def verify_magic_link(token) do
# # #     query = from s in Staff,
# # #             where: s.magic_link_token == ^token,
# # #             where: s.magic_link_expires_at > ^NaiveDateTime.utc_now(),
# # #             where: s.is_active == true,
# # #             preload: [:health_brand, :staff_role]

# # #     case Repo.one(query) do
# # #       nil -> {:error, :invalid_or_expired_token}
# # #       staff ->
# # #         # Clear the token and update login stats
# # #         changeset = Ecto.Changeset.change(staff, %{
# # #           magic_link_token: nil,
# # #           magic_link_expires_at: nil,
# # #           last_login_at: NaiveDateTime.utc_now(),
# # #           login_count: (staff.login_count || 0) + 1
# # #         })

# # #         case Repo.update(changeset) do
# # #           {:ok, staff} -> {:ok, staff}
# # #           {:error, _} -> {:error, :update_failed}
# # #         end
# # #     end
# # #   end

# # # end


# # defmodule Laura.Accounts do
# #   import Ecto.Query, warn: false
# #   alias Laura.Repo
# #   alias Laura.Accounts.{Staff, StaffRole}

# #   # Staff Roles
# #   def list_staff_roles, do: Repo.all(StaffRole)
# #   def get_staff_role!(id), do: Repo.get!(StaffRole, id)
# #   def get_staff_role_by_name(name), do: Repo.get_by(StaffRole, name: name)

# #   # Staff
# #   def list_staffs, do: Repo.all(Staff)
# #   def get_staff!(id), do: Repo.get!(Staff, id)

# #   def get_staff_by_email_and_health_brand(email, health_brand_subdomain) do
# #     query = from s in Staff,
# #             join: hb in assoc(s, :health_brand),
# #             where: s.email == ^email and hb.subdomain == ^health_brand_subdomain,
# #             where: s.is_active == true,
# #             preload: [:health_brand, :staff_role]

# #     case Repo.one(query) do
# #       nil -> {:error, :not_found}
# #       staff -> {:ok, staff}
# #     end
# #   end

# #   def create_staff(attrs \\ %{}) do
# #     %Staff{}
# #     |> Staff.changeset(attrs)
# #     |> Repo.insert()
# #   end

# #   # Magic Link Authentication - VERSIÓN SIMPLE Y FUNCIONAL
# #   def request_magic_link(email, health_brand_subdomain, remote_ip) do
# #     with {:ok, staff} <- get_staff_by_email_and_health_brand(email, health_brand_subdomain),
# #          {:ok, _staff} <- generate_and_send_magic_link(staff, remote_ip) do
# #       {:ok, :magic_link_sent}
# #     end
# #   end

# #   # defp generate_and_send_magic_link(staff, remote_ip) do
# #   #   magic_link_token = generate_magic_link_token()
# #   #   expires_at = NaiveDateTime.add(NaiveDateTime.utc_now(), 15 * 60) # 15 minutes
# #   #   # Manejar campos que podrían ser nil
# #   #   current_attempts = staff.magic_link_attempts || 0

# #   #   changeset = Staff.magic_link_changeset(staff, %{
# #   #     magic_link_token: magic_link_token,
# #   #     magic_link_sent_at: NaiveDateTime.utc_now(),
# #   #     magic_link_expires_at: expires_at,
# #   #     last_magic_link_ip: remote_ip,
# #   #     magic_link_attempts: current_attempts + 1
# #   #   })

# #   #   case Repo.update(changeset) do
# #   #     {:ok, staff} ->
# #   #       deliver_staff_magic_link(staff, staff.health_brand)
# #   #       {:ok, staff}
# #   #     {:error, changeset} ->
# #   #       {:error, changeset}
# #   #   end
# #   # end

# #   defp generate_and_send_magic_link(staff, remote_ip) do
# #     magic_link_token = generate_magic_link_token()
# #     now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
# #     expires_at = NaiveDateTime.add(now, 15 * 60) |> NaiveDateTime.truncate(:second)

# #     # Manejar campos que podrían ser nil
# #     current_attempts = staff.magic_link_attempts || 0

# #     changeset = Staff.magic_link_changeset(staff, %{
# #       magic_link_token: magic_link_token,
# #       magic_link_sent_at: now,
# #       magic_link_expires_at: expires_at,
# #       last_magic_link_ip: remote_ip,
# #       magic_link_attempts: current_attempts + 1
# #     })

# #     case Repo.update(changeset) do
# #       {:ok, staff} ->
# #         deliver_staff_magic_link(staff, staff.health_brand)
# #         {:ok, staff}
# #       {:error, changeset} ->
# #         {:error, changeset}
# #     end
# #   end

# #   defp generate_magic_link_token do
# #     :crypto.strong_rand_bytes(32)
# #     |> Base.url_encode64()
# #     |> String.replace(~r/[\+\/]/, "-")
# #     |> String.trim("=")
# #   end

# #   def deliver_staff_magic_link(staff, health_brand) do
# #     base_url = LauraWeb.Endpoint.url()
# #     magic_link_url = "#{base_url}/auth/verify/#{staff.magic_link_token}"

# #     # 🎯 VERSIÓN CONSOLA - FUNCIONAL Y PROFESIONAL
# #     IO.puts("")
# #     IO.puts("🔐" <> String.duplicate("═", 60) <> "🔐")
# #     IO.puts("🎯 MAGIC LINK GENERADO - #{health_brand.name}")
# #     IO.puts("📧 Para: #{staff.email}")
# #     IO.puts("🔗 Enlace: #{magic_link_url}")
# #     IO.puts("⏰ Expira: #{staff.magic_link_expires_at}")
# #     IO.puts("🏥 Health Brand: #{health_brand.name} (#{health_brand.subdomain})")
# #     IO.puts("🔐" <> String.duplicate("═", 60) <> "🔐")
# #     IO.puts("💡 En producción esto enviaría un email automático")
# #     IO.puts("")

# #     {:ok, %{url: magic_link_url, email_sent: false}}
# #   end

# #   # def verify_magic_link(token) do
# #   #   query = from s in Staff,
# #   #           where: s.magic_link_token == ^token,
# #   #           where: s.magic_link_expires_at > ^NaiveDateTime.utc_now(),
# #   #           where: s.is_active == true,
# #   #           preload: [:health_brand, :staff_role]

# #   #   case Repo.one(query) do
# #   #     nil -> {:error, :invalid_or_expired_token}
# #   #     staff ->
# #   #       # Clear the token and update login stats
# #   #       changeset = Ecto.Changeset.change(staff, %{
# #   #         magic_link_token: nil,
# #   #         magic_link_expires_at: nil,
# #   #         last_login_at: NaiveDateTime.utc_now(),
# #   #         login_count: (staff.login_count || 0) + 1
# #   #       })

# #   #       case Repo.update(changeset) do
# #   #         {:ok, staff} -> {:ok, staff}
# #   #         {:error, _} -> {:error, :update_failed}
# #   #       end
# #   #   end
# #   # end

# #   def verify_magic_link(token) do
# #     query = from s in Staff,
# #             where: s.magic_link_token == ^token,
# #             where: s.magic_link_expires_at > ^NaiveDateTime.utc_now(),
# #             where: s.is_active == true,
# #             preload: [:health_brand, :staff_role]

# #     case Repo.one(query) do
# #       nil -> {:error, :invalid_or_expired_token}
# #       staff ->
# #         # Clear the token and update login stats - TRUNCAR MICROSEGUNDOS
# #         now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

# #         changeset = Ecto.Changeset.change(staff, %{
# #           magic_link_token: nil,
# #           magic_link_expires_at: nil,
# #           last_login_at: now,
# #           login_count: (staff.login_count || 0) + 1
# #         })

# #         case Repo.update(changeset) do
# #           {:ok, staff} -> {:ok, staff}
# #           {:error, _} -> {:error, :update_failed}
# #         end
# #     end
# #   end

# #   def magic_link_changeset(staff, attrs) do
# #     staff
# #     |> cast(attrs, [
# #       :magic_link_token, :magic_link_sent_at, :magic_link_expires_at,
# #       :last_magic_link_ip, :magic_link_attempts
# #     ])
# #     |> validate_required([:magic_link_token, :magic_link_sent_at, :magic_link_expires_at])
# #   end
# # end


# defmodule Laura.Accounts do
#   import Ecto.Query, warn: false
#   alias Laura.Repo
#   alias Laura.Accounts.{Staff, StaffRole}

#   # Staff Roles
#   def list_staff_roles, do: Repo.all(StaffRole)
#   def get_staff_role!(id), do: Repo.get!(StaffRole, id)
#   def get_staff_role_by_name(name), do: Repo.get_by(StaffRole, name: name)

#   # Staff
#   def list_staffs, do: Repo.all(Staff)
#   def get_staff!(id), do: Repo.get!(Staff, id)

#   def get_staff_by_email_and_health_brand(email, health_brand_subdomain) do
#     query = from s in Staff,
#             join: hb in assoc(s, :health_brand),
#             where: s.email == ^email and hb.subdomain == ^health_brand_subdomain,
#             where: s.is_active == true,
#             preload: [:health_brand, :staff_role]

#     case Repo.one(query) do
#       nil -> {:error, :not_found}
#       staff -> {:ok, staff}
#     end
#   end

#   def create_staff(attrs \\ %{}) do
#     %Staff{}
#     |> Staff.changeset(attrs)
#     |> Repo.insert()
#   end

#   # Magic Link Authentication
#   def request_magic_link(email, health_brand_subdomain, remote_ip) do
#     with {:ok, staff} <- get_staff_by_email_and_health_brand(email, health_brand_subdomain),
#          {:ok, _staff} <- generate_and_send_magic_link(staff, remote_ip) do
#       {:ok, :magic_link_sent}
#     end
#   end

#   defp generate_and_send_magic_link(staff, remote_ip) do
#     magic_link_token = generate_magic_link_token()
#     now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
#     expires_at = NaiveDateTime.add(now, 15 * 60) |> NaiveDateTime.truncate(:second)

#     current_attempts = staff.magic_link_attempts || 0

#     changeset = Staff.magic_link_changeset(staff, %{
#       magic_link_token: magic_link_token,
#       magic_link_sent_at: now,
#       magic_link_expires_at: expires_at,
#       last_magic_link_ip: remote_ip,
#       magic_link_attempts: current_attempts + 1
#     })

#     case Repo.update(changeset) do
#       {:ok, staff} ->
#         deliver_staff_magic_link(staff, staff.health_brand)
#         {:ok, staff}
#       {:error, changeset} ->
#         {:error, changeset}
#     end
#   end

#   defp generate_magic_link_token do
#     :crypto.strong_rand_bytes(32)
#     |> Base.url_encode64()
#     |> String.replace(~r/[\+\/]/, "-")
#     |> String.trim("=")
#   end

#   def deliver_staff_magic_link(staff, health_brand) do
#     base_url = LauraWeb.Endpoint.url()
#     magic_link_url = "#{base_url}/auth/verify/#{staff.magic_link_token}"

#     IO.puts("")
#     IO.puts("🔐" <> String.duplicate("═", 60) <> "🔐")
#     IO.puts("🎯 MAGIC LINK GENERADO - #{health_brand.name}")
#     IO.puts("📧 Para: #{staff.email}")
#     IO.puts("🔗 Enlace: #{magic_link_url}")
#     IO.puts("⏰ Expira: #{staff.magic_link_expires_at}")
#     IO.puts("🏥 Health Brand: #{health_brand.name} (#{health_brand.subdomain})")
#     IO.puts("🔐" <> String.duplicate("═", 60) <> "🔐")
#     IO.puts("💡 En producción esto enviaría un email automático")
#     IO.puts("")

#     {:ok, %{url: magic_link_url, email_sent: false}}
#   end

#   def verify_magic_link(token) do
#     query = from s in Staff,
#             where: s.magic_link_token == ^token,
#             where: s.magic_link_expires_at > ^NaiveDateTime.utc_now(),
#             where: s.is_active == true,
#             preload: [:health_brand, :staff_role]

#     case Repo.one(query) do
#       nil -> {:error, :invalid_or_expired_token}
#       staff ->
#         # Clear the token and update login stats
#         now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

#         changeset = Ecto.Changeset.change(staff, %{
#           magic_link_token: nil,
#           magic_link_expires_at: nil,
#           last_login_at: now,
#           login_count: (staff.login_count || 0) + 1
#         })

#         case Repo.update(changeset) do
#           {:ok, staff} -> {:ok, staff}
#           {:error, _} -> {:error, :update_failed}
#         end
#     end
#   end
# end

defmodule Laura.Accounts do
  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.Accounts.{Staff, StaffRole}

  # Staff Roles
  def list_staff_roles, do: Repo.all(StaffRole)
  def get_staff_role!(id), do: Repo.get!(StaffRole, id)
  def get_staff_role_by_name(name), do: Repo.get_by(StaffRole, name: name)

  # Staff
  def list_staffs, do: Repo.all(Staff)
  def get_staff!(id), do: Repo.get!(Staff, id)

  def get_staff_by_email_and_health_brand(email, health_brand_subdomain) do
    query = from s in Staff,
            join: hb in assoc(s, :health_brand),
            where: s.email == ^email and hb.subdomain == ^health_brand_subdomain,
            where: s.is_active == true,
            preload: [:health_brand, :staff_role]

    case Repo.one(query) do
      nil -> {:error, :not_found}
      staff -> {:ok, staff}
    end
  end

  def get_staff_by_email(email) do
    query = from s in Staff,
            where: s.email == ^email,
            where: s.is_active == true

    case Repo.one(query) do
      nil -> {:error, :not_found}
      staff -> {:ok, staff}
    end
  end

  def create_staff(attrs \\ %{}) do
    %Staff{}
    |> Staff.changeset(attrs)
    |> Repo.insert()
  end

  # Magic Link Authentication
  def request_magic_link(email, health_brand_subdomain, remote_ip) do
    with {:ok, staff} <- get_staff_by_email_and_health_brand(email, health_brand_subdomain),
         {:ok, _staff} <- generate_and_send_magic_link(staff, remote_ip) do
      {:ok, :magic_link_sent}
    end
  end

  defp generate_and_send_magic_link(staff, remote_ip) do
    magic_link_token = generate_magic_link_token()
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    expires_at = NaiveDateTime.add(now, 15 * 60) |> NaiveDateTime.truncate(:second)

    current_attempts = staff.magic_link_attempts || 0

    changeset = Staff.magic_link_changeset(staff, %{
      magic_link_token: magic_link_token,
      magic_link_sent_at: now,
      magic_link_expires_at: expires_at,
      last_magic_link_ip: remote_ip,
      magic_link_attempts: current_attempts + 1
    })

    case Repo.update(changeset) do
      {:ok, staff} ->
        deliver_staff_magic_link(staff, staff.health_brand)
        {:ok, staff}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp generate_magic_link_token do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64()
    |> String.replace(~r/[\+\/]/, "-")
    |> String.trim("=")
  end

  def deliver_staff_magic_link(staff, health_brand) do
    base_url = LauraWeb.Endpoint.url()
    magic_link_url = "#{base_url}/auth/verify/#{staff.magic_link_token}"

    IO.puts("")
    IO.puts("🔐" <> String.duplicate("═", 60) <> "🔐")
    IO.puts("🎯 MAGIC LINK GENERADO - #{health_brand.name}")
    IO.puts("📧 Para: #{staff.email}")
    IO.puts("🔗 Enlace: #{magic_link_url}")
    IO.puts("⏰ Expira: #{staff.magic_link_expires_at}")
    IO.puts("🏥 Health Brand: #{health_brand.name} (#{health_brand.subdomain})")
    IO.puts("🔐" <> String.duplicate("═", 60) <> "🔐")
    IO.puts("💡 En producción esto enviaría un email automático")
    IO.puts("")

    {:ok, %{url: magic_link_url, email_sent: false}}
  end

  def verify_magic_link(token) do
    query = from s in Staff,
            where: s.magic_link_token == ^token,
            where: s.magic_link_expires_at > ^NaiveDateTime.utc_now(),
            where: s.is_active == true,
            preload: [:health_brand, :staff_role]

    case Repo.one(query) do
      nil -> {:error, :invalid_or_expired_token}
      staff ->
        # Clear the token and update login stats
        now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

        changeset = Ecto.Changeset.change(staff, %{
          magic_link_token: nil,
          magic_link_expires_at: nil,
          last_login_at: now,
          login_count: (staff.login_count || 0) + 1
        })

        case Repo.update(changeset) do
          {:ok, staff} -> {:ok, staff}
          {:error, _} -> {:error, :update_failed}
        end
    end
  end
end
