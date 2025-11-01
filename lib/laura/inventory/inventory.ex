# defmodule Laura.Inventory.Inventory do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "inventory" do
#     belongs_to :health_brand, Laura.Platform.HealthBrand

#     # Información del item
#     field :name, :string
#     field :description, :string
#     field :category, :string
#     field :item_type, :string

#     # Stock y precios
#     field :current_stock, :integer, default: 0
#     field :min_stock, :integer, default: 0
#     field :max_stock, :integer
#     field :unit_cost, :decimal
#     field :unit_price, :decimal

#     # Información específica por tipo
#     field :medication_data, :map, default: %{}
#     field :supply_data, :map, default: %{}
#     field :equipment_data, :map, default: %{}

#     # Metadata
#     field :is_active, :boolean, default: true
#     field :reorder_needed, :boolean, default: false

#     # Relaciones
#     has_many :inventory_transactions, Laura.Inventory.InventoryTransaction

#     timestamps(type: :naive_datetime)
#   end

#   def changeset(inventory, attrs) do
#     inventory
#     |> cast(attrs, [
#       :health_brand_id, :name, :description, :category, :item_type,
#       :current_stock, :min_stock, :max_stock, :unit_cost, :unit_price,
#       :medication_data, :supply_data, :equipment_data, :is_active, :reorder_needed
#     ])
#     |> validate_required([:health_brand_id, :name, :category, :item_type])
#     |> validate_inclusion(:item_type, ["medication", "supply", "equipment"])
#     |> validate_number(:current_stock, greater_than_or_equal_to: 0)
#     |> validate_number(:min_stock, greater_than_or_equal_to: 0)
#   end
# end

defmodule Laura.Inventory.Inventory do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "inventory" do
    belongs_to :health_brand, Laura.Platform.HealthBrand

    field :name, :string
    field :description, :string
    field :category, :string
    field :item_type, :string
    field :current_stock, :integer
    field :min_stock, :integer
    field :unit_cost, :decimal
    field :unit_price, :decimal
    field :medication_data, :map, default: %{}
    field :supply_data, :map, default: %{}

    has_many :inventory_transactions, Laura.Inventory.InventoryTransaction

    timestamps(type: :naive_datetime)
  end

  def changeset(inventory, attrs) do
    inventory
    |> cast(attrs, [
      :health_brand_id,
      :name,
      :description,
      :category,
      :item_type,
      :current_stock,
      :min_stock,
      :unit_cost,
      :unit_price,
      :medication_data,
      :supply_data
    ])
    |> validate_required([:health_brand_id, :name, :category, :item_type, :current_stock])
  end
end
