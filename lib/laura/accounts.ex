# lib/laura/accounts.ex
defmodule Laura.Accounts do
  import Ecto.Query, warn: false
  alias Laura.Repo

  alias Laura.Accounts.{Staff, StaffRole}

  def list_staffs, do: Repo.all(Staff)

  def get_staff!(id), do: Repo.get!(Staff, id)

  def get_staff_by_email(email), do: Repo.get_by(Staff, email: email)

  def create_staff(attrs \\ %{}) do
    %Staff{}
    |> Staff.registration_changeset(attrs)
    |> Repo.insert()
  end

  def get_admin_role do
    Repo.get_by(StaffRole, name: "admin")
  end

  def deliver_staff_magic_link(staff, health_brand) do
    # Por ahora solo logueamos el token - luego implementaremos email real
    IO.puts("=== MAGIC LINK PARA #{staff.email} ===")
    IO.puts("Token: #{staff.magic_link_token}")
    IO.puts("URL: http://#{health_brand.subdomain}.laura.ia3.art/auth/confirm?token=#{staff.magic_link_token}")
    IO.puts("=====================================")

    {:ok, staff}
  end

  # Esto permite que Accounts sea supervisado
  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link do
    # No necesita hacer nada especial al iniciar
    :ignore
  end
end
