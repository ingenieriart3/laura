# priv/repo/migrations/20240101000002_create_staff_and_roles.exs
defmodule Laura.Repo.Migrations.CreateStaffAndRoles do
  use Ecto.Migration

  def change do
    create table(:staff_roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :permissions, :map, default: %{}
      timestamps()
    end

    create table(:staffs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :first_name, :string
      add :last_name, :string
      add :password_hash, :string
      add :confirmed_at, :naive_datetime
      add :magic_link_token, :string
      add :magic_link_sent_at, :naive_datetime

      # Relaciones
      add :health_brand_id, references(:health_brands, type: :binary_id), null: false
      add :staff_role_id, references(:staff_roles, type: :binary_id)

      timestamps()
    end

    create unique_index(:staff_roles, [:name])
    create unique_index(:staffs, [:email])
    create index(:staffs, [:health_brand_id])
    create index(:staffs, [:staff_role_id])
    create index(:staffs, [:magic_link_token])
  end
end
