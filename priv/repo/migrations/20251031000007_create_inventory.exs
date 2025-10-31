defmodule Laura.Repo.Migrations.CreateInventory do
  use Ecto.Migration

  def change do
    create table(:inventory, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false

      # Información del item
      add :name, :string, null: false
      add :description, :text
      add :category, :string, null: false
      add :item_type, :string, null: false # medication, supply, equipment

      # Stock y precios
      add :current_stock, :integer, default: 0
      add :min_stock, :integer, default: 0
      add :max_stock, :integer
      add :unit_cost, :decimal, precision: 10, scale: 2
      add :unit_price, :decimal, precision: 10, scale: 2

      # Información específica por tipo
      add :medication_data, :map, default: %{} # Para medicamentos
      add :supply_data, :map, default: %{}     # Para insumos
      add :equipment_data, :map, default: %{}  # Para equipamiento

      # Metadata
      add :is_active, :boolean, default: true
      add :reorder_needed, :boolean, default: false

      timestamps(type: :naive_datetime)
    end

    create index(:inventory, [:health_brand_id])
    create index(:inventory, [:category])
    create index(:inventory, [:item_type])
    create index(:inventory, [:is_active])
  end
end
