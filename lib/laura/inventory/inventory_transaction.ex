defmodule Laura.Inventory.InventoryTransaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "inventory_transactions" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :inventory, Laura.Inventory.Inventory
    belongs_to :treatment_session, Laura.MedicalRecord.TreatmentSession
    belongs_to :staff, Laura.Accounts.Staff

    # Datos de la transacción
    field :transaction_type, :string
    field :quantity, :integer
    field :unit_cost, :decimal
    field :total_cost, :decimal

    # Referencias
    field :reference_number, :string
    field :supplier_info, :map, default: %{}

    # Metadata
    field :notes, :string
    field :transaction_date, :naive_datetime

    timestamps(type: :naive_datetime)
  end

  def changeset(inventory_transaction, attrs) do
    inventory_transaction
    |> cast(attrs, [
      :health_brand_id, :inventory_id, :treatment_session_id, :staff_id,
      :transaction_type, :quantity, :unit_cost, :total_cost,
      :reference_number, :supplier_info, :notes, :transaction_date
    ])
    |> validate_required([:health_brand_id, :inventory_id, :staff_id, :transaction_type, :quantity, :transaction_date])
    |> validate_inclusion(:transaction_type, ["purchase", "usage", "adjustment", "return", "waste"])
    |> validate_number(:quantity, greater_than: 0)
  end
end
