# lib/laura/platform/health_brand.ex
defmodule Laura.Platform.HealthBrand do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "health_brands" do
    field :name, :string
    field :subdomain, :string
    field :is_active, :boolean

    # Subscription fields
    field :subscription_status, :string
    field :trial_ends_at, :utc_datetime
    field :trial_activated_at, :utc_datetime
    field :current_period_end, :utc_datetime
    field :reminders_used_current_month, :integer

    # MercadoPago fields
    field :mp_customer_id, :string
    field :mp_subscription_id, :string
    field :mp_preapproval_id, :string

    # Relationships
    belongs_to :subscription_plan, Laura.Billing.SubscriptionPlan
    has_many :staffs, Laura.Accounts.Staff
    has_many :payment_events, Laura.Billing.PaymentEvent

    timestamps()
  end

  def registration_changeset(health_brand, attrs, trial_days \\ 30) do
    trial_ends_at = DateTime.utc_now() |> DateTime.add(trial_days, :day)

    health_brand
    |> cast(attrs, [:name, :subdomain])
    |> validate_required([:name, :subdomain])
    |> unique_constraint(:subdomain)
    |> put_change(:trial_ends_at, trial_ends_at)
    |> put_change(:trial_activated_at, DateTime.utc_now())
    |> put_change(:subscription_status, "trial")
    |> put_change(:is_active, true)
  end

  def update_subscription_changeset(health_brand, attrs) do
    health_brand
    |> cast(attrs, [
      :subscription_status, :current_period_end,
      :mp_customer_id, :mp_subscription_id, :mp_preapproval_id
    ])
  end
end
