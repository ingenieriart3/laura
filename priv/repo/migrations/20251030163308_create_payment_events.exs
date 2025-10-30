# priv/repo/migrations/20251030013005_create_payment_events.exs
defmodule Laura.Repo.Migrations.CreatePaymentEvents do
  use Ecto.Migration

  def change do
    create table(:payment_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false
      add :event_type, :string, null: false
      add :amount, :decimal, precision: 10, scale: 2
      add :currency, :string, default: "ARS"
      add :status, :string, null: false

      # MercadoPago fields
      add :mp_payment_id, :string
      add :mp_merchant_order_id, :string
      add :mp_preference_id, :string
      add :mp_notification_url, :string

      # Metadata
      add :metadata, :map, default: %{}

      timestamps(type: :naive_datetime)
    end

    create index(:payment_events, [:health_brand_id])
    create index(:payment_events, [:mp_payment_id])
    create index(:payment_events, [:mp_merchant_order_id])
  end
end
