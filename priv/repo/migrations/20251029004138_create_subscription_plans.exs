# priv/repo/migrations/20240101000000_create_subscription_plans.exs
defmodule Laura.Repo.Migrations.CreateSubscriptionPlans do
  use Ecto.Migration

  def change do
    create table(:subscription_plans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :code, :string, null: false  # "basic", "standard", "premium"
      add :price_monthly, :integer, null: false  # en centavos (4900 = $49.00)
      add :staff_limit, :integer
      add :reminder_limit, :integer
      add :features, :map, default: %{}
      add :is_active, :boolean, default: true
      add :recommended, :boolean, default: false

      timestamps()
    end

    create unique_index(:subscription_plans, [:code])
  end
end
