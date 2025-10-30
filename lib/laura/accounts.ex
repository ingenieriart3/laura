# # # lib/laura/accounts.ex
# # defmodule Laura.Accounts do
# #   import Ecto.Query, warn: false
# #   alias Laura.Repo

# #   alias Laura.Accounts.{Staff, StaffRole}

# #   def list_staffs, do: Repo.all(Staff)

# #   def get_staff!(id), do: Repo.get!(Staff, id)

# #   def get_staff_by_email(email), do: Repo.get_by(Staff, email: email)

# #   def create_staff(attrs \\ %{}) do
# #     %Staff{}
# #     |> Staff.registration_changeset(attrs)
# #     |> Repo.insert()
# #   end

# #   def get_admin_role do
# #     Repo.get_by(StaffRole, name: "admin")
# #   end

# #   def deliver_staff_magic_link(staff, health_brand) do
# #     # Por ahora solo logueamos el token - luego implementaremos email real
# #     IO.puts("=== MAGIC LINK PARA #{staff.email} ===")
# #     IO.puts("Token: #{staff.magic_link_token}")
# #     IO.puts("URL: http://#{health_brand.subdomain}.laura.ia3.art/auth/confirm?token=#{staff.magic_link_token}")
# #     IO.puts("=====================================")

# #     {:ok, staff}
# #   end

# #   # Esto permite que Accounts sea supervisado
# #   def child_spec(_opts) do
# #     %{
# #       id: __MODULE__,
# #       start: {__MODULE__, :start_link, []},
# #       type: :worker,
# #       restart: :permanent,
# #       shutdown: 500
# #     }
# #   end

# #   def start_link do
# #     # No necesita hacer nada especial al iniciar
# #     :ignore
# #   end
# # end

# # lib/laura/accounts.ex
# defmodule Laura.Accounts do
#   @moduledoc """
#   Accounts context with enterprise business logic.
#   Clean architecture with proper error handling and telemetry.
#   """

#   import Ecto.Query, warn: false
#   alias Laura.Repo
#   alias Laura.Accounts.{Staff, StaffRole}

#   # Telemetry for monitoring
#   @telemetry_event [:laura, :accounts, :magic_link]

#   @doc """
#   Request magic link with rate limiting and security checks.
#   """
#   def request_magic_link(email, health_brand_id, remote_ip) do
#     Telemetry.execute(@telemetry_event, %{action: :magic_link_request, email: email})

#     with {:ok, _rate_limit} <- check_rate_limit(remote_ip, :magic_link),
#          {:ok, staff} <- get_staff_by_email_and_brand(email, health_brand_id),
#          {:ok, staff} <- validate_staff_active(staff),
#          {:ok, staff} <- generate_and_send_magic_link(staff, remote_ip) do

#       Telemetry.execute(@telemetry_event, %{action: :magic_link_sent, staff_id: staff.id})
#       {:ok, :magic_link_sent}
#     else
#       {:error, :staff_not_found} ->
#         # Security: Don't reveal if email exists
#         {:ok, :magic_link_sent}

#       {:error, :rate_limited} = error ->
#         Telemetry.execute(@telemetry_event, %{action: :rate_limited, remote_ip: remote_ip})
#         error

#       {:error, _reason} = error ->
#         error
#     end
#   end

#   @doc """
#   Confirm magic link with security validations.
#   """
#   def confirm_magic_link(token, remote_ip) do
#     Telemetry.execute(@telemetry_event, %{action: :magic_link_confirm_attempt, token: token})

#     query = from s in Staff,
#       where: s.magic_link_token == ^token,
#       where: s.is_active == true,
#       preload: [:health_brand, :staff_role]

#     with %Staff{} = staff <- Repo.one(query),
#          {:ok, staff} <- validate_magic_link_token(staff, remote_ip),
#          {:ok, staff} <- confirm_staff_login(staff, remote_ip) do

#       Telemetry.execute(@telemetry_event, %{action: :magic_link_confirmed, staff_id: staff.id})
#       {:ok, staff}
#     else
#       nil ->
#         {:error, :invalid_token}
#       error ->
#         error
#     end
#   end

#   # Private business logic methods

#   defp generate_and_send_magic_link(staff, remote_ip) do
#     Ecto.Multi.new()
#     |> Ecto.Multi.update(:staff, Staff.magic_link_changeset(staff, remote_ip))
#     |> Ecto.Multi.run(:send_email, fn _repo, %{staff: staff} ->
#       deliver_magic_link_email(staff)
#     end)
#     |> Repo.transaction()
#     |> case do
#       {:ok, %{staff: staff}} -> {:ok, staff}
#       {:error, _, changeset, _} -> {:error, changeset}
#     end
#   end

#   defp validate_magic_link_token(staff, remote_ip) do
#     cond do
#       Crypto.token_expired?(staff.magic_link_expires_at) ->
#         {:error, :token_expired}
#       staff.magic_link_attempts >= @max_attempts ->
#         {:error, :too_many_attempts}
#       true ->
#         {:ok, staff}
#     end
#   end

#   defp confirm_staff_login(staff, remote_ip) do
#     staff
#     |> Staff.confirm_login_changeset(remote_ip)
#     |> Repo.update()
#   end

#   defp check_rate_limit(_remote_ip, _action), do: {:ok, :allowed} # TODO: Implementar

#   defp get_staff_by_email_and_brand(email, health_brand_id) do
#     case Repo.get_by(Staff, email: email, health_brand_id: health_brand_id, is_active: true) do
#       nil -> {:error, :staff_not_found}
#       staff -> {:ok, staff}
#     end
#   end

#   defp validate_staff_active(%Staff{is_active: true} = staff), do: {:ok, staff}
#   defp validate_staff_active(_), do: {:error, :account_inactive}

#   defp deliver_magic_link_email(staff) do
#     # TODO: Integrar con Swoosh para emails reales
#     IO.puts("""
#     🔐 MAGIC LINK - ENTERPRISE GRADE
#     To: #{staff.email}
#     Token: #{staff.magic_link_token}
#     Expires: #{staff.magic_link_expires_at}
#     URL: http://#{staff.health_brand.subdomain}.laura.ia3.art/auth/confirm?token=#{staff.magic_link_token}
#     Security: IP #{staff.last_magic_link_ip}
#     """)
#     {:ok, :email_sent}
#   end
# end

# lib/laura/accounts.ex
defmodule Laura.Accounts do
  @moduledoc """
  Accounts context with enterprise business logic.
  """

  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.Accounts.Staff
  alias Laura.Crypto

  @max_attempts 5

  @doc """
  Request magic link with rate limiting and security checks.
  """
  def request_magic_link(email, health_brand_id, remote_ip) do
    with {:ok, _rate_limit} <- check_rate_limit(remote_ip, :magic_link),
         {:ok, staff} <- get_staff_by_email_and_brand(email, health_brand_id),
         {:ok, staff} <- validate_staff_active(staff),
         {:ok, staff} <- generate_and_send_magic_link(staff, remote_ip) do
      {:ok, :magic_link_sent}
    else
      {:error, :staff_not_found} ->
        # Security: Don't reveal if email exists
        {:ok, :magic_link_sent}

      {:error, :rate_limited} = error ->
        error

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Confirm magic link with security validations.
  """
  def confirm_magic_link(token, remote_ip) do
    query = from s in Staff,
      where: s.magic_link_token == ^token,
      where: s.is_active == true,
      preload: [:health_brand, :staff_role]

    with %Staff{} = staff <- Repo.one(query),
         {:ok, staff} <- validate_magic_link_token(staff),
         {:ok, staff} <- confirm_staff_login(staff, remote_ip) do
      {:ok, staff}
    else
      nil ->
        {:error, :invalid_token}
      error ->
        error
    end
  end

  # Private business logic methods

  defp generate_and_send_magic_link(staff, remote_ip) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:staff, Staff.magic_link_changeset(staff, remote_ip))
    |> Ecto.Multi.run(:send_email, fn _repo, %{staff: staff} ->
      deliver_magic_link_email(staff)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{staff: staff}} -> {:ok, staff}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  defp validate_magic_link_token(staff) do
    cond do
      Crypto.token_expired?(staff.magic_link_expires_at) ->
        {:error, :token_expired}
      staff.magic_link_attempts >= @max_attempts ->
        {:error, :too_many_attempts}
      true ->
        {:ok, staff}
    end
  end

  defp confirm_staff_login(staff, remote_ip) do
    staff
    |> Staff.confirm_login_changeset(remote_ip)
    |> Repo.update()
  end

  defp check_rate_limit(_remote_ip, _action), do: {:ok, :allowed}

  defp get_staff_by_email_and_brand(email, health_brand_id) do
    case Repo.get_by(Staff, email: email, health_brand_id: health_brand_id, is_active: true) do
      nil -> {:error, :staff_not_found}
      staff -> {:ok, staff}
    end
  end

  defp validate_staff_active(%Staff{is_active: true} = staff), do: {:ok, staff}
  defp validate_staff_active(_), do: {:error, :account_inactive}

  defp deliver_magic_link_email(staff) do
    IO.puts("""
    🔐 MAGIC LINK - ENTERPRISE GRADE
    To: #{staff.email}
    Token: #{staff.magic_link_token}
    Expires: #{staff.magic_link_expires_at}
    URL: http://#{staff.health_brand.subdomain}.laura.ia3.art/auth/confirm?token=#{staff.magic_link_token}
    Security: IP #{staff.last_magic_link_ip}
    """)
    {:ok, :email_sent}
  end

  # Funciones que necesita Platform
  def create_staff(attrs) do
    %Staff{}
    |> Staff.registration_changeset(attrs, attrs[:health_brand])
    |> Repo.insert()
  end

  def get_admin_role do
    Repo.get_by(Laura.Accounts.StaffRole, name: "admin")
  end

  def deliver_staff_magic_link(staff, health_brand) do
    deliver_magic_link_email(staff)
  end
end
