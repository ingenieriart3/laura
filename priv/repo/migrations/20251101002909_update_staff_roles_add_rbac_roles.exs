defmodule Laura.Repo.Migrations.UpdateStaffRolesAddRbacRoles do
  use Ecto.Migration

  def change do
    # Primero agregamos los nuevos roles
    alter table(:staff_roles) do
      add :role_type, :string, default: "clinical"  # clinical, administrative, support
      add :is_system_role, :boolean, default: false
    end

    # Crear índice para búsquedas por tipo
    create index(:staff_roles, [:role_type])
    create index(:staff_roles, [:is_system_role])
  end
end
