defmodule Laura.Repo.Migrations.CreateInventoryTransactions do
  use Ecto.Migration

  def change do
    create table(:inventory_transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false
      add :inventory_id, :binary_id, null: false
      add :treatment_session_id, :binary_id
      add :staff_id, :binary_id, null: false

      # Datos de la transacción
      add :transaction_type, :string, null: false # purchase, usage, adjustment, return
      add :quantity, :integer, null: false
      add :unit_cost, :decimal, precision: 10, scale: 2
      add :total_cost, :decimal, precision: 10, scale: 2

      # Referencias
      add :reference_number, :string
      add :supplier_info, :map, default: %{}

      # Metadata
      add :notes, :text
      add :transaction_date, :naive_datetime, null: false

      timestamps(type: :naive_datetime)
    end

    create index(:inventory_transactions, [:health_brand_id])
    create index(:inventory_transactions, [:inventory_id])
    create index(:inventory_transactions, [:treatment_session_id])
    create index(:inventory_transactions, [:staff_id])
    create index(:inventory_transactions, [:transaction_type])
    create index(:inventory_transactions, [:transaction_date])
  end
end
