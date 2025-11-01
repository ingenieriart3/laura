defmodule Laura.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :staff_role_id, references(:staff_roles, type: :binary_id, on_delete: :delete_all), null: false
      add :module, :string, null: false  # "medical_records", "appointments", "inventory"
      add :action, :string, null: false  # "read", "write", "delete", "manage"
      add :scope, :string, null: false, default: "own"  # "own", "all", "none"

      timestamps(type: :naive_datetime)
    end

    create index(:permissions, [:staff_role_id])
    create unique_index(:permissions, [:staff_role_id, :module, :action])
  end
end
