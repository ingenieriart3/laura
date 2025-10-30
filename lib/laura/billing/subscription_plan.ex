# lib/laura/billing/subscription_plan.ex
defmodule Laura.Billing.SubscriptionPlan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "subscription_plans" do
    field :name, :string
    field :code, :string
    field :price_monthly, :integer
    field :staff_limit, :integer
    field :reminder_limit, :integer
    field :features, :map
    field :is_active, :boolean
    field :recommended, :boolean

    has_many :health_brands, Laura.Platform.HealthBrand

    timestamps(type: :naive_datetime)
  end

  def changeset(subscription_plan, attrs) do
    subscription_plan
    |> cast(attrs, [
      :name, :code, :price_monthly, :staff_limit, :reminder_limit,
      :features, :is_active, :recommended
    ])
    |> validate_required([:name, :code, :price_monthly])
    |> unique_constraint(:code)
  end
end
