# priv/repo/migrations/20240101000001_create_health_brands.exs
defmodule Laura.Repo.Migrations.CreateHealthBrands do
  use Ecto.Migration

  def change do
    create table(:health_brands, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :subdomain, :string, null: false
      add :is_active, :boolean, default: true

      # Campos de trial y suscripción
      add :subscription_status, :string, default: "trial"
      add :trial_ends_at, :utc_datetime
      add :trial_activated_at, :utc_datetime
      add :current_period_end, :utc_datetime
      add :reminders_used_current_month, :integer, default: 0

      # Campos para MercadoPago
      add :mp_customer_id, :string
      add :mp_subscription_id, :string
      add :mp_preapproval_id, :string  # Para suscripciones recurrentes

      # Relaciones
      add :subscription_plan_id, references(:subscription_plans, type: :binary_id)

      timestamps()
    end

    create unique_index(:health_brands, [:subdomain])
    create index(:health_brands, [:subscription_plan_id])
    create index(:health_brands, [:mp_customer_id])
  end
end
