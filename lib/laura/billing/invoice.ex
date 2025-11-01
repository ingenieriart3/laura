# defmodule Laura.Billing.Invoice do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "invoices" do
#     belongs_to :health_brand, Laura.Platform.HealthBrand
#     belongs_to :patient, Laura.Accounts.Patient
#     belongs_to :appointment, Laura.Scheduling.Appointment

#     # Información de facturación
#     field :invoice_number, :string
#     field :invoice_date, :date
#     field :due_date, :date
#     field :status, :string, default: "draft"

#     # Montos y pagos
#     field :subtotal, :decimal
#     field :tax_amount, :decimal, default: 0.0
#     field :total_amount, :decimal
#     field :amount_paid, :decimal, default: 0.0
#     field :balance_due, :decimal

#     # Items de la factura
#     field :line_items, :map, default: %{}

#     # Información de pago
#     field :payment_method, :string
#     field :paid_at, :naive_datetime
#     field :payment_reference, :string

#     # Facturación electrónica
#     field :cae_number, :string
#     field :cae_due_date, :date
#     field :afip_data, :map, default: %{}

#     timestamps(type: :naive_datetime)
#   end

#   def changeset(invoice, attrs) do
#     invoice
#     |> cast(attrs, [
#       :health_brand_id, :patient_id, :appointment_id, :invoice_number, :invoice_date, :due_date,
#       :status, :subtotal, :tax_amount, :total_amount, :amount_paid, :balance_due,
#       :line_items, :payment_method, :paid_at, :payment_reference, :cae_number, :cae_due_date, :afip_data
#     ])
#     |> validate_required([:health_brand_id, :patient_id, :invoice_number, :invoice_date, :subtotal, :total_amount])
#     |> validate_inclusion(:status, ["draft", "sent", "paid", "overdue", "cancelled"])
#     |> unique_constraint([:health_brand_id, :invoice_number])
#   end
# end

defmodule Laura.Billing.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "invoices" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :patient, Laura.Accounts.Patient
    belongs_to :appointment, Laura.Scheduling.Appointment

    field :invoice_number, :string
    field :invoice_date, :date
    field :due_date, :date
    field :status, :string
    field :subtotal, :decimal
    field :tax_amount, :decimal
    field :total_amount, :decimal
    field :balance_due, :decimal
    field :line_items, :map, default: %{}

    has_many :payment_events, Laura.Billing.PaymentEvent

    timestamps(type: :naive_datetime)
  end

  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :health_brand_id,
      :patient_id,
      :appointment_id,
      :invoice_number,
      :invoice_date,
      :due_date,
      :status,
      :subtotal,
      :tax_amount,
      :total_amount,
      :balance_due,
      :line_items
    ])
    |> validate_required([:health_brand_id, :patient_id, :invoice_number, :invoice_date, :status])
  end
end
