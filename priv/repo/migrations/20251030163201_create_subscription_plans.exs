# priv/repo/migrations/20251030013001_create_subscription_plans.exs
defmodule Laura.Repo.Migrations.CreateSubscriptionPlans do
  use Ecto.Migration

  def change do
    create table(:subscription_plans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :code, :string, null: false
      add :description, :text
      add :monthly_price, :decimal, precision: 10, scale: 2
      add :yearly_price, :decimal, precision: 10, scale: 2
      add :reminders_included, :integer, null: false
      add :extra_reminder_price, :decimal, precision: 10, scale: 2
      add :features, :map, default: %{}
      add :is_active, :boolean, default: true

      timestamps(type: :naive_datetime)
    end

    create unique_index(:subscription_plans, [:code])
  end
end
