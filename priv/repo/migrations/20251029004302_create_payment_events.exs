# priv/repo/migrations/20240101000003_create_payment_events.exs
defmodule Laura.Repo.Migrations.CreatePaymentEvents do
  use Ecto.Migration

  def change do
    create table(:payment_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_type, :string, null: false
      add :mp_payment_id, :string
      add :mp_merchant_order_id, :string
      add :status, :string
      add :amount, :integer
      add :metadata, :map, default: %{}

      add :health_brand_id, references(:health_brands, type: :binary_id), null: false

      timestamps()
    end

    create index(:payment_events, [:health_brand_id])
    create index(:payment_events, [:mp_payment_id])
    create index(:payment_events, [:mp_merchant_order_id])
  end
end
