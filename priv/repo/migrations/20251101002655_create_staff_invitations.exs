defmodule Laura.Repo.Migrations.CreateStaffInvitations do
  use Ecto.Migration

  def change do
    create table(:staff_invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :invited_by_staff_id, references(:staffs, type: :binary_id, on_delete: :nilify_all), null: false
      add :email, :string, null: false
      add :staff_role_id, references(:staff_roles, type: :binary_id, on_delete: :nilify_all), null: false
      add :token, :string, null: false
      add :status, :string, null: false, default: "pending"  # pending, accepted, expired, cancelled
      add :expires_at, :naive_datetime, null: false
      add :accepted_at, :naive_datetime

      timestamps(type: :naive_datetime)
    end

    create index(:staff_invitations, [:health_brand_id])
    create index(:staff_invitations, [:invited_by_staff_id])
    create index(:staff_invitations, [:staff_role_id])
    create unique_index(:staff_invitations, [:token])
    create index(:staff_invitations, [:email, :health_brand_id])
    create index(:staff_invitations, [:status])
    create index(:staff_invitations, [:expires_at])
  end
end
