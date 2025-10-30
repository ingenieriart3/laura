# priv/repo/migrations/20251030013003_create_health_brands.exs
defmodule Laura.Repo.Migrations.CreateHealthBrands do
  use Ecto.Migration

  def change do
    create table(:health_brands, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :subdomain, :string, null: false

      # Subscription fields
      add :subscription_plan_id, :binary_id
      add :subscription_status, :string, default: "trial"
      add :trial_ends_at, :naive_datetime
      add :trial_activated_at, :naive_datetime
      add :current_period_end, :naive_datetime
      add :reminders_used_current_month, :integer, default: 0

      # MercadoPago fields
      add :mp_customer_id, :string
      add :mp_subscription_id, :string
      add :mp_preapproval_id, :string

      timestamps(type: :naive_datetime)
    end

    create unique_index(:health_brands, [:subdomain])
    create index(:health_brands, [:subscription_plan_id])
    create index(:health_brands, [:mp_customer_id])
  end
end
