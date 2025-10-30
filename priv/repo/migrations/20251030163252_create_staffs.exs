# priv/repo/migrations/20251030013004_create_staffs.exs
defmodule Laura.Repo.Migrations.CreateStaffs do
  use Ecto.Migration

  def change do
    create table(:staffs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :health_brand_id, :binary_id, null: false
      add :staff_role_id, :binary_id, null: false

      # Magic Link Authentication
      add :magic_link_token, :string
      add :magic_link_sent_at, :naive_datetime
      add :magic_link_expires_at, :naive_datetime
      add :magic_link_attempts, :integer, default: 0
      add :last_magic_link_ip, :string

      # Account State
      add :confirmed_at, :naive_datetime
      add :is_active, :boolean, default: true
      add :last_login_at, :naive_datetime
      add :login_count, :integer, default: 0

      # Security & Recovery
      add :reset_token, :string
      add :reset_sent_at, :naive_datetime

      timestamps(type: :naive_datetime)
    end

    create unique_index(:staffs, [:email, :health_brand_id])
    create index(:staffs, [:health_brand_id])
    create index(:staffs, [:staff_role_id])
    create index(:staffs, [:magic_link_token])
  end
end
