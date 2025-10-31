defmodule Laura.Billing.SubscriptionPlan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "subscription_plans" do
    field :name, :string
    field :code, :string
    field :description, :string
    field :price, :decimal
    field :billing_cycle, :string, default: "monthly"
    field :reminders_included, :integer, default: 0
    field :patients_limit, :integer
    field :staff_limit, :integer
    field :storage_limit_mb, :integer
    field :features, :map, default: %{}
    field :is_active, :boolean, default: true
    field :is_public, :boolean, default: true
    field :sort_order, :integer, default: 0
    field :stripe_price_id, :string
    field :stripe_product_id, :string

    # Comentar temporalmente hasta que HealthBrand exista
    # has_many :health_brands, Laura.Platform.HealthBrand

    timestamps(type: :naive_datetime)
  end

  @doc false
  def changeset(subscription_plan, attrs) do
    subscription_plan
    |> cast(attrs, [
      :name, :code, :description, :price, :billing_cycle,
      :reminders_included, :patients_limit, :staff_limit,
      :storage_limit_mb, :features, :is_active, :is_public,
      :sort_order, :stripe_price_id, :stripe_product_id
    ])
    |> validate_required([:name, :code, :price, :billing_cycle])
    |> validate_inclusion(:billing_cycle, ~w(monthly yearly))
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:reminders_included, greater_than_or_equal_to: 0)
    |> unique_constraint(:code)
  end
end
