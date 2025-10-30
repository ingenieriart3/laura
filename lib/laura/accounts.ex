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

  # Nueva función para verificar disponibilidad de email globalmente
  def is_email_available?(email) do
    case get_staff_by_email(email) do
      {:ok, _} -> false
      {:error, :not_found} -> true
    end
  end
end
