defmodule Laura.Repo.Migrations.CreateSubscriptionPlans do
  use Ecto.Migration

  def change do
    create table(:subscription_plans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :code, :string, null: false
      add :description, :text
      add :price, :decimal, precision: 10, scale: 2, null: false
      add :billing_cycle, :string, null: false, default: "monthly"
      add :reminders_included, :integer, null: false, default: 0
      add :patients_limit, :integer
      add :staff_limit, :integer
      add :storage_limit_mb, :integer
      add :features, :map, default: %{}
      add :is_active, :boolean, default: true, null: false
      add :is_public, :boolean, default: true, null: false
      add :sort_order, :integer, default: 0
      add :stripe_price_id, :string
      add :stripe_product_id, :string

      timestamps(type: :naive_datetime)
    end

    create unique_index(:subscription_plans, [:code])
    create index(:subscription_plans, [:is_active, :is_public])
    create index(:subscription_plans, [:sort_order])
  end
end
