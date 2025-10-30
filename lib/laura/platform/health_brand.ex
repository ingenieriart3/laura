defmodule Laura.Platform.HealthBrand do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "health_brands" do
    field :name, :string
    field :subdomain, :string

    # Subscription fields
    field :subscription_status, :string, default: "trial"
    field :trial_ends_at, :naive_datetime
    field :trial_activated_at, :naive_datetime
    field :current_period_end, :naive_datetime
    field :reminders_used_current_month, :integer, default: 0

    # MercadoPago fields
    field :mp_customer_id, :string
    field :mp_subscription_id, :string
    field :mp_preapproval_id, :string

    # Relations
    belongs_to :subscription_plan, Laura.Billing.SubscriptionPlan

    has_many :staffs, Laura.Accounts.Staff
    has_many :payment_events, Laura.Billing.PaymentEvent

    timestamps(type: :naive_datetime)
  end

  def changeset(health_brand, attrs) do
    health_brand
    |> cast(attrs, [
      :name, :subdomain, :subscription_plan_id, :subscription_status,
      :trial_ends_at, :trial_activated_at, :current_period_end,
      :mp_customer_id, :mp_subscription_id, :mp_preapproval_id
    ])
    |> validate_required([:name, :subdomain])
    |> unique_constraint(:subdomain)
    |> validate_inclusion(:subscription_status, ["trial", "active", "past_due", "canceled", "incomplete"])
  end

  # def trial_changeset(health_brand, attrs) do
  #   health_brand
  #   |> changeset(attrs)
  #   |> put_change(:trial_activated_at, NaiveDateTime.utc_now())
  #   |> put_change(:trial_ends_at, NaiveDateTime.add(NaiveDateTime.utc_now(), 30 * 24 * 60 * 60))
  #   |> put_change(:subscription_status, "trial")
  # end
  def trial_changeset(health_brand, attrs) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    trial_ends_at = NaiveDateTime.add(now, 30 * 24 * 60 * 60) |> NaiveDateTime.truncate(:second)

    health_brand
    |> changeset(attrs)
    |> put_change(:trial_activated_at, now)
    |> put_change(:trial_ends_at, trial_ends_at)
    |> put_change(:subscription_status, "trial")
  end
end
