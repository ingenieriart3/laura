defmodule Laura.Billing.SubscriptionPlan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "subscription_plans" do
    field :name, :string
    field :code, :string
    field :description, :string
    field :monthly_price, :decimal
    field :yearly_price, :decimal
    field :reminders_included, :integer
    field :extra_reminder_price, :decimal
    field :features, :map
    field :is_active, :boolean

    timestamps(type: :naive_datetime)
  end

  def changeset(subscription_plan, attrs) do
    subscription_plan
    |> cast(attrs, [
      :name, :code, :description, :monthly_price, :yearly_price,
      :reminders_included, :extra_reminder_price, :features, :is_active
    ])
    |> validate_required([:name, :code, :reminders_included])
    |> unique_constraint(:code)
  end
end
