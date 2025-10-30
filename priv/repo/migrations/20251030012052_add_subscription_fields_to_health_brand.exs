# priv/repo/migrations/20251030011153_add_subscription_fields_to_health_brand.exs
defmodule Laura.Repo.Migrations.AddSubscriptionFieldsToHealthBrand do
  use Ecto.Migration

  def change do
    alter table(:health_brands) do
      # Subscription fields
      add :subscription_status, :string, default: "trial"
      add :trial_ends_at, :naive_datetime
      add :trial_activated_at, :naive_datetime
      add :current_period_end, :naive_datetime
      add :reminders_used_current_month, :integer, default: 0

      # MercadoPago fields
      add :mp_customer_id, :string
      add :mp_subscription_id, :string
      add :mp_preapproval_id, :string
    end
  end
end
