defmodule Laura.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false
      add :patient_id, :binary_id, null: false
      add :appointment_id, :binary_id

      # Información de facturación
      add :invoice_number, :string, null: false
      add :invoice_date, :date, null: false
      add :due_date, :date
      add :status, :string, default: "draft" # draft, sent, paid, overdue, cancelled

      # Montos y pagos
      add :subtotal, :decimal, precision: 10, scale: 2, null: false
      add :tax_amount, :decimal, precision: 10, scale: 2, default: 0.0
      add :total_amount, :decimal, precision: 10, scale: 2, null: false
      add :amount_paid, :decimal, precision: 10, scale: 2, default: 0.0
      add :balance_due, :decimal, precision: 10, scale: 2

      # Items de la factura
      add :line_items, :map, default: %{} # [{description, quantity, unit_price, amount}]

      # Información de pago
      add :payment_method, :string
      add :paid_at, :naive_datetime
      add :payment_reference, :string

      # Facturación electrónica
      add :cae_number, :string # Clave de Autorización Electrónica
      add :cae_due_date, :date
      add :afip_data, :map, default: %{}

      timestamps(type: :naive_datetime)
    end

    create unique_index(:invoices, [:health_brand_id, :invoice_number])
    create index(:invoices, [:health_brand_id])
    create index(:invoices, [:patient_id])
    create index(:invoices, [:appointment_id])
    create index(:invoices, [:status])
    create index(:invoices, [:invoice_date])
  end
end
