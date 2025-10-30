# lib/laura/billing/payment_event.ex
defmodule Laura.Billing.PaymentEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "payment_events" do
    field :event_type, :string
    field :mp_payment_id, :string
    field :mp_merchant_order_id, :string
    field :status, :string
    field :amount, :integer
    field :metadata, :map, default: %{}

    belongs_to :health_brand, Laura.Platform.HealthBrand

    timestamps(type: :naive_datetime)
  end

  def changeset(payment_event, attrs) do
    payment_event
    |> cast(attrs, [
      :event_type, :mp_payment_id, :mp_merchant_order_id,
      :status, :amount, :metadata, :health_brand_id
    ])
    |> validate_required([:event_type, :health_brand_id])
  end
end
