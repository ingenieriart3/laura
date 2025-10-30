# priv/repo/migrations/20251030005552_change_datetime_fields_to_naive_datetime.exs
defmodule Laura.Repo.Migrations.ChangeDatetimeFieldsToNaiveDatetime do
  use Ecto.Migration

  def change do
    # HealthBrands table
    alter table(:health_brands) do
      modify :trial_ends_at, :naive_datetime
      modify :trial_activated_at, :naive_datetime
      modify :current_period_end, :naive_datetime
      modify :inserted_at, :naive_datetime
      modify :updated_at, :naive_datetime
    end

    # Staffs table
    alter table(:staffs) do
      modify :magic_link_sent_at, :naive_datetime
      modify :magic_link_expires_at, :naive_datetime
      modify :confirmed_at, :naive_datetime
      modify :last_login_at, :naive_datetime
      modify :reset_sent_at, :naive_datetime
      modify :inserted_at, :naive_datetime
      modify :updated_at, :naive_datetime
    end

    # SubscriptionPlans table
    alter table(:subscription_plans) do
      modify :inserted_at, :naive_datetime
      modify :updated_at, :naive_datetime
    end

    # StaffRoles table
    alter table(:staff_roles) do
      modify :inserted_at, :naive_datetime
      modify :updated_at, :naive_datetime
    end

    # PaymentEvents table
    alter table(:payment_events) do
      modify :inserted_at, :naive_datetime
      modify :updated_at, :naive_datetime
    end
  end
end
