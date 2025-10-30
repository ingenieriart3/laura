# priv/repo/migrations/20251030011152_add_magic_link_fields_to_staff.exs
defmodule Laura.Repo.Migrations.AddMagicLinkFieldsToStaff do
  use Ecto.Migration

  def change do
    alter table(:staffs) do
      # Magic Link fields
      add :magic_link_token, :string
      add :magic_link_sent_at, :naive_datetime
      add :magic_link_expires_at, :naive_datetime
      add :magic_link_attempts, :integer, default: 0
      add :last_magic_link_ip, :string

      # Account state
      add :confirmed_at, :naive_datetime
      add :is_active, :boolean, default: true
      add :last_login_at, :naive_datetime
      add :login_count, :integer, default: 0

      # Security
      add :reset_token, :string
      add :reset_sent_at, :naive_datetime
    end

    # Index for magic link token
    create index(:staffs, [:magic_link_token])
  end
end
