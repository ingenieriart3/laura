# priv/repo/migrations/20251030011154_create_staff_roles.exs
defmodule Laura.Repo.Migrations.CreateStaffRoles do
  use Ecto.Migration

  def change do
    create table(:staff_roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :permissions, :map, default: %{}

      timestamps(type: :naive_datetime)
    end

    create unique_index(:staff_roles, [:name])
  end
end
