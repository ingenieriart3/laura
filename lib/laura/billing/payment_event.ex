# defmodule Laura.Billing.PaymentEvent do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "payment_events" do
#     field :event_type, :string
#     field :amount, :decimal
#     field :currency, :string
#     field :status, :string

#     # MercadoPago fields
#     field :mp_payment_id, :string
#     field :mp_merchant_order_id, :string
#     field :mp_preference_id, :string
#     field :mp_notification_url, :string

#     # Metadata
#     field :metadata, :map

#     # Relations
#     belongs_to :health_brand, Laura.Platform.HealthBrand

#     timestamps(type: :naive_datetime)
#   end

#   def changeset(payment_event, attrs) do
#     payment_event
#     |> cast(attrs, [
#       :health_brand_id, :event_type, :amount, :currency, :status,
#       :mp_payment_id, :mp_merchant_order_id, :mp_preference_id,
#       :mp_notification_url, :metadata
#     ])
#     |> validate_required([:health_brand_id, :event_type, :status])
#     |> validate_inclusion(:event_type, ["payment", "subscription", "refund"])
#     |> validate_inclusion(:status, ["pending", "approved", "rejected", "cancelled"])
#   end
# end

defmodule Laura.Billing.PaymentEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "payment_events" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :invoice, Laura.Billing.Invoice

    field :payment_method, :string
    field :amount, :decimal
    field :transaction_id, :string
    field :status, :string
    field :processed_at, :naive_datetime

    timestamps(type: :naive_datetime)
  end

  def changeset(payment_event, attrs) do
    payment_event
    |> cast(attrs, [
      :health_brand_id,
      :invoice_id,
      :payment_method,
      :amount,
      :transaction_id,
      :status,
      :processed_at
    ])
    |> validate_required([:health_brand_id, :payment_method, :amount, :status])
  end
end
